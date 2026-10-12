/// What happens to each Today item when a new logical day is noticed.
///
/// The rule is idempotent and needs no memory of the last run, so any device can apply it at any time.
public enum DayRollover {
  public enum Action: Hashable, Sendable {
    /// The item has no history yet, so it was put on the list outside the app. Today claims it.
    case adopt
    case keep
    /// The item is unfinished from an earlier day. It goes back to the Backlog.
    case returnToBacklog
  }

  public static func action(for item: TodayItem, today: LogicalDay) -> Action {
    guard item.bucket == .today else { return .keep }
    guard let lastDay = item.metadata?.days.last else { return .adopt }
    if lastDay >= today { return .keep }
    return item.isCompleted ? .keep : .returnToBacklog
  }

  /// The items as they should be after rollover, in the same order.
  ///
  /// Unchanged items come back as they were.
  public static func apply(to items: [TodayItem], today: LogicalDay) -> [TodayItem] {
    var nextOrder = items.compactMap(\.order).max().map { $0 + 1 } ?? 0
    return items.map { item in
      switch action(for: item, today: today) {
      case .keep:
        return item
      case .returnToBacklog:
        return item.movedToBacklog()
      case .adopt:
        let adopted = item.movedToToday(on: today, order: nextOrder)
        nextOrder += 1
        return adopted
      }
    }
  }
}
