import Foundation
import TodayKit

/// Canned items for screenshots, used when the app is launched with `-demo`.
///
/// Nothing here touches Reminders. The store keeps these in memory and edits them in place.
enum DemoData {
  static var isEnabled: Bool { LaunchArguments.isDemo }

  /// A settings store in its own suite, emptied on every launch, so demo runs never read or write the real settings.
  static var settingsStore: SettingsStore {
    let suiteName = "engineering.xo.Today.demo"
    let defaults = UserDefaults(suiteName: suiteName) ?? .standard
    defaults.removePersistentDomain(forName: suiteName)
    return SettingsStore(defaults: defaults)
  }

  static func items(today: LogicalDay, endOfDay: EndOfDay) -> [TodayItem] {
    let calendar = Calendar.current
    var items: [TodayItem] = []

    let todayTitles = [
      ("Water the plants", CheckState.done),
      ("Write back to Sam", .doing),
      ("Book the dentist", .todo),
      ("Draft the talk outline", .todo),
      ("Walk before sunset", .todo),
    ]
    // With -finished every Today item is done, which is the celebration the empty state shows.
    for (index, (title, state)) in todayTitles.enumerated() {
      var item = TodayItem(id: "today-\(index)", title: title, bucket: .today, creationDate: .now)
      item = item.movedToToday(on: today, order: index)
      let finishedAt = calendar.date(byAdding: .hour, value: -2, to: .now) ?? .now
      item = item.setting(LaunchArguments.isFinished ? .done : state, completedAt: finishedAt)
      items.append(item)
    }

    let backlogTitles = [
      "Fix the squeaky door", "Plan the camping trip", "Read the design review", "Call the landlord",
      "Renew the passport", "Sort the photo library", "Try the new bakery",
    ]
    for (index, title) in backlogTitles.enumerated() {
      items.append(TodayItem(id: "backlog-\(index)", title: title, bucket: .backlog, creationDate: .now))
    }

    // Two weeks of history, with a few finished per day and one day left alone.
    let outcomes = [
      (3, 3), (2, 4), (0, 2), (4, 4), (1, 3), (3, 3), (0, 0), (2, 2), (1, 4), (3, 3), (2, 3), (4, 4), (0, 1), (3, 3),
    ]
    for (offset, (completed, total)) in outcomes.enumerated() {
      let day = today.advanced(by: -(offset + 1))
      let interval = day.interval(endOfDay: endOfDay, calendar: calendar)
      for index in 0..<total {
        var item = TodayItem(
          id: "history-\(offset)-\(index)", title: "Done that day", bucket: .today, creationDate: interval.start)
        item = item.movedToToday(on: day, order: index)
        // Finished within the day counts for that day's ring. The rest were finished days later, which keeps the
        // ring honest and keeps the Backlog free of a dozen leftovers.
        let finishedAt =
          index < completed
          ? interval.start.addingTimeInterval(3600 * Double(index + 8))
          : interval.end.addingTimeInterval(3600 * 30)
        item = item.setting(.done, completedAt: finishedAt)
        items.append(item)
      }
    }
    return items
  }
}
