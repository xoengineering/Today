import Foundation

/// One day's answer to whether you got done what you put on your Today list.
public struct DayRing: Hashable, Sendable {
  public enum Outcome: Hashable, Sendable {
    /// Nothing was on the list.
    case empty
    case allDone
    case someDone
    case noneDone
  }

  public let day: LogicalDay
  public let completed: Int
  public let total: Int

  public init(day: LogicalDay, completed: Int, total: Int) {
    self.day = day
    self.completed = completed
    self.total = total
  }

  public var outcome: Outcome {
    if total == 0 { return .empty }
    if completed == total { return .allDone }
    if completed == 0 { return .noneDone }
    return .someDone
  }

  /// The share of the ring that is green, 0 through 1.
  public var completedFraction: Double {
    total == 0 ? 0 : Double(completed) / Double(total)
  }

  /// Counts the items that were on the Today list on a day, and how many were finished within that day.
  public static func compute(
    day: LogicalDay, items: [TodayItem], endOfDay: EndOfDay, calendar: Calendar = .current
  ) -> Self {
    let interval = day.interval(endOfDay: endOfDay, calendar: calendar)
    let onTheList = items.filter { $0.metadata?.days.contains(day) == true }
    let finished = onTheList.filter { item in
      guard item.isCompleted, let completionDate = item.completionDate else { return false }
      return interval.contains(completionDate)
    }
    return Self(day: day, completed: finished.count, total: onTheList.count)
  }

  /// Rings for every day from `first` through `last`, oldest first.
  public static func computeRange(
    from first: LogicalDay, through last: LogicalDay, items: [TodayItem], endOfDay: EndOfDay,
    calendar: Calendar = .current
  ) -> [Self] {
    var rings: [Self] = []
    var day = first
    while day <= last {
      rings.append(compute(day: day, items: items, endOfDay: endOfDay, calendar: calendar))
      day = day.advanced(by: 1, calendar: calendar)
    }
    return rings
  }
}
