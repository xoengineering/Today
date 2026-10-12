import EventKit
import Foundation
import Observation
import TodayKit
import WidgetKit
import os

/// The single EventKit adapter.
///
/// Everything the app knows about Reminders goes through here. Reads produce `TodayItem` values. Writes look the
/// reminder up again by identifier, change only what differs, and save. Every external change, from another device
/// or the Reminders app, arrives as `EKEventStoreChanged` and triggers a reload.
@MainActor
@Observable
final class RemindersStore {
  private(set) var authorization: EKAuthorizationStatus
  private(set) var todayItems: [TodayItem] = []
  private(set) var backlogItems: [TodayItem] = []
  /// How many Today items were finished within the current logical day, for the empty state to celebrate.
  private(set) var completedTodayCount = 0
  /// Bumps on every reload, so views that derive from the full history know when to recompute.
  private(set) var reloadCount = 0
  private(set) var lists: [EKCalendar] = []
  private(set) var todayList: EKCalendar?
  private(set) var backlogList: EKCalendar?
  private(set) var lastError: String? {
    didSet {
      if let lastError {
        logger.error("\(lastError, privacy: .public)")
      }
    }
  }
  var settings: AppSettings {
    didSet { settingsStore.save(settings) }
  }

  private let eventStore = EKEventStore()
  private let settingsStore: SettingsStore
  private var changeObserver: (any NSObjectProtocol)?
  private let logger = Logger(subsystem: "engineering.xo.Today", category: "RemindersStore")

  init(settingsStore: SettingsStore = AppGroup.settingsStore) {
    self.settingsStore = settingsStore
    self.settings = settingsStore.load()
    self.authorization = EKEventStore.authorizationStatus(for: .reminder)
  }

  var hasAccess: Bool { authorization == .fullAccess }

  var today: LogicalDay {
    LogicalDay(containing: .now, endOfDay: settings.endOfDay)
  }

  var allItems: [TodayItem] { todayItems + backlogItems }

  // MARK: Lifecycle

  func requestAccess() async {
    do {
      _ = try await eventStore.requestFullAccessToReminders()
    } catch {
      // The status below says what the user chose. The error adds nothing.
    }
    authorization = EKEventStore.authorizationStatus(for: .reminder)
    if hasAccess {
      await start()
    }
  }

  /// Resolves the two lists, loads, and keeps loading on every change.
  ///
  /// Safe to call more than once.
  func start() async {
    guard hasAccess else { return }
    resolveLists()
    await reload()
    guard changeObserver == nil else { return }
    changeObserver = NotificationCenter.default.addObserver(
      forName: .EKEventStoreChanged, object: eventStore, queue: nil
    ) { [weak self] _ in
      Task { @MainActor in
        await self?.reload()
      }
    }
  }

  // MARK: Lists

  private func resolveLists() {
    lists = eventStore.calendars(for: .reminder).filter(\.allowsContentModifications)
    todayList = resolveList(identifier: settings.todayListIdentifier, title: "Today")
    backlogList = resolveList(identifier: settings.backlogListIdentifier, title: "Backlog")
    settings.todayListIdentifier = todayList?.calendarIdentifier
    settings.backlogListIdentifier = backlogList?.calendarIdentifier
    logger.info(
      "Lists: today=\(self.todayList?.title ?? "none", privacy: .public) backlog=\(self.backlogList?.title ?? "none", privacy: .public) of \(self.lists.count)"
    )
  }

  private func resolveList(identifier: String?, title: String) -> EKCalendar? {
    if let identifier, let list = lists.first(where: { $0.calendarIdentifier == identifier }) {
      return list
    }
    if let list = lists.first(where: { $0.title == title }) {
      return list
    }
    return createList(titled: title)
  }

  private func createList(titled title: String) -> EKCalendar? {
    let list = EKCalendar(for: .reminder, eventStore: eventStore)
    list.title = title
    guard let source = eventStore.defaultCalendarForNewReminders()?.source ?? eventStore.sources.first else {
      lastError = "No account can hold a reminders list."
      return nil
    }
    list.source = source
    do {
      try eventStore.saveCalendar(list, commit: true)
      lists.append(list)
      return list
    } catch {
      lastError = "Couldn't create the \(title) list: \(error.localizedDescription)"
      return nil
    }
  }

  func useTodayList(_ list: EKCalendar) async {
    todayList = list
    settings.todayListIdentifier = list.calendarIdentifier
    await reload()
  }

  func useBacklogList(_ list: EKCalendar) async {
    backlogList = list
    settings.backlogListIdentifier = list.calendarIdentifier
    await reload()
  }

  func setEndOfDay(_ endOfDay: EndOfDay) async {
    settings.endOfDay = endOfDay
    await reload()
  }

  // MARK: Reading

  func reload() async {
    guard hasAccess, let todayList, let backlogList else { return }
    let fetched = await fetchItems(in: [todayList, backlogList], todayListIdentifier: todayList.calendarIdentifier)
    let rolled = DayRollover.apply(to: fetched, today: today)
    let changed = zip(fetched, rolled).filter { $0 != $1 }.map(\.1)
    if !changed.isEmpty {
      save(changed)
    }
    todayItems = TodayOrdering.sorted(rolled.filter { $0.bucket == .today && !$0.isCompleted })
    backlogItems = rolled.filter { $0.bucket == .backlog && !$0.isCompleted }
      .sorted { ($0.creationDate ?? .distantPast) < ($1.creationDate ?? .distantPast) }
    completedTodayCount = DayRing.compute(day: today, items: rolled, endOfDay: settings.endOfDay).completed
    reloadCount += 1
    WidgetCenter.shared.reloadAllTimelines()
    logger.info(
      "Reloaded: \(fetched.count) reminders, \(changed.count) rolled over, today=\(self.todayItems.count) backlog=\(self.backlogItems.count)"
    )
  }

  /// Every reminder in the two lists, completed ones included, for the ring history.
  func fetchHistory() async -> [TodayItem] {
    guard let todayList, let backlogList else { return [] }
    return await fetchItems(in: [todayList, backlogList], todayListIdentifier: todayList.calendarIdentifier)
  }

  private func fetchItems(in calendars: [EKCalendar], todayListIdentifier: String) async -> [TodayItem] {
    let predicate = eventStore.predicateForReminders(in: calendars)
    return await withCheckedContinuation { continuation in
      // EKReminder is not Sendable, so the mapping happens here, on EventKit's queue.
      // The closure is @Sendable so it is not inferred to be main-actor isolated, which EventKit's queue would trip.
      eventStore.fetchReminders(matching: predicate) { @Sendable reminders in
        let items = (reminders ?? []).map { TodayItem(reminder: $0, todayListIdentifier: todayListIdentifier) }
        continuation.resume(returning: items)
      }
    }
  }

  // MARK: Writing

  func add(title: String, to bucket: Bucket) {
    let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty, let todayList, let backlogList else { return }
    let reminder = EKReminder(eventStore: eventStore)
    reminder.title = trimmed
    reminder.calendar = bucket == .today ? todayList : backlogList
    if bucket == .today {
      let metadata = ItemMetadata(order: todayItems.count, state: .todo, days: [today])
      reminder.notes = NotesFooter.join(body: "", metadata: metadata)
    }
    do {
      try eventStore.save(reminder, commit: true)
    } catch {
      lastError = "Couldn't add the reminder: \(error.localizedDescription)"
    }
  }

  func set(_ item: TodayItem, to state: CheckState) {
    save([item.setting(state)])
  }

  func moveToToday(_ item: TodayItem) {
    save([item.movedToToday(on: today, order: todayItems.count)])
  }

  func moveToBacklog(_ item: TodayItem) {
    save([item.movedToBacklog()])
  }

  func moveTodayItems(fromOffsets source: IndexSet, toOffset destination: Int) {
    let reordered = TodayOrdering.moving(todayItems, fromOffsets: source, toOffset: destination)
    let changed = reordered.filter { item in todayItems.first { $0.id == item.id } != item }
    todayItems = reordered
    save(changed)
  }

  func rename(_ item: TodayItem, to title: String) {
    let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty, trimmed != item.title else { return }
    var renamed = item
    renamed.title = trimmed
    save([renamed])
  }

  func delete(_ item: TodayItem) {
    guard let reminder = eventStore.calendarItem(withIdentifier: item.id) as? EKReminder else { return }
    do {
      try eventStore.remove(reminder, commit: true)
    } catch {
      lastError = "Couldn't delete the reminder: \(error.localizedDescription)"
    }
  }

  private func save(_ items: [TodayItem]) {
    guard let todayList, let backlogList else { return }
    for item in items {
      guard let reminder = eventStore.calendarItem(withIdentifier: item.id) as? EKReminder else { continue }
      reminder.apply(item, todayList: todayList, backlogList: backlogList)
      do {
        try eventStore.save(reminder, commit: false)
      } catch {
        lastError = "Couldn't save \"\(item.title)\": \(error.localizedDescription)"
      }
    }
    do {
      try eventStore.commit()
    } catch {
      lastError = "Couldn't save changes: \(error.localizedDescription)"
    }
  }
}
