import EventKit
import TodayKit
import WidgetKit

struct TodayListEntry: TimelineEntry {
  let date: Date
  let items: [TodayItem]
  let hasAccess: Bool

  static let placeholder = Self(
    date: .now,
    items: [
      TodayItem(id: "1", title: "Water the plants", bucket: .today, metadata: ItemMetadata(order: 0)),
      TodayItem(id: "2", title: "Write back to Sam", bucket: .today, metadata: ItemMetadata(order: 1, state: .doing)),
      TodayItem(id: "3", title: "Book the dentist", bucket: .today, metadata: ItemMetadata(order: 2)),
    ],
    hasAccess: true)
}

/// Reads the Today list straight from Reminders, using the list the app chose.
struct TodayListProvider: TimelineProvider {
  func placeholder(in context: Context) -> TodayListEntry {
    .placeholder
  }

  func getSnapshot(in context: Context, completion: @escaping @Sendable (TodayListEntry) -> Void) {
    if context.isPreview {
      completion(.placeholder)
      return
    }
    Task { completion(await entry()) }
  }

  func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<TodayListEntry>) -> Void) {
    Task {
      let entry = await entry()
      // The list resets at the end of the day, so the widget asks again then.
      let settings = AppGroup.settingsStore.load()
      let today = LogicalDay(containing: .now, endOfDay: settings.endOfDay)
      let nextDay = today.interval(endOfDay: settings.endOfDay).end
      completion(Timeline(entries: [entry], policy: .after(nextDay)))
    }
  }

  private func entry() async -> TodayListEntry {
    guard EKEventStore.authorizationStatus(for: .reminder) == .fullAccess else {
      return TodayListEntry(date: .now, items: [], hasAccess: false)
    }
    let settings = AppGroup.settingsStore.load()
    let eventStore = EKEventStore()
    guard let identifier = settings.todayListIdentifier,
      let list = eventStore.calendar(withIdentifier: identifier)
    else {
      return TodayListEntry(date: .now, items: [], hasAccess: true)
    }
    let predicate = eventStore.predicateForIncompleteReminders(withDueDateStarting: nil, ending: nil, calendars: [list])
    let items: [TodayItem] = await withCheckedContinuation { continuation in
      eventStore.fetchReminders(matching: predicate) { @Sendable reminders in
        let items = (reminders ?? []).map { TodayItem(reminder: $0, todayListIdentifier: identifier) }
        continuation.resume(returning: items)
      }
    }
    return TodayListEntry(date: .now, items: TodayOrdering.sorted(items), hasAccess: true)
  }
}
