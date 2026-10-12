import Foundation

/// The order of the Today list, and how it is kept dense after a drag.
public enum TodayOrdering {
  /// Items by their stored order, then by creation, then by title.
  ///
  /// Items with no order go last.
  public static func sorted(_ items: [TodayItem]) -> [TodayItem] {
    items.sorted { lhs, rhs in
      switch (lhs.order, rhs.order) {
      case (let left?, let right?) where left != right: return left < right
      case (.some, .none): return true
      case (.none, .some): return false
      default: break
      }
      switch (lhs.creationDate, rhs.creationDate) {
      case (let left?, let right?) where left != right: return left < right
      default: return lhs.title.localizedStandardCompare(rhs.title) == .orderedAscending
      }
    }
  }

  /// The same items with `order` set to their index, so gaps and ties disappear.
  public static func reassigningOrders(_ items: [TodayItem]) -> [TodayItem] {
    items.enumerated().map { index, item in
      var item = item
      var metadata = item.metadata ?? ItemMetadata()
      metadata.order = index
      item.metadata = metadata
      return item
    }
  }

  /// A drag result: the items moved, then renumbered.
  ///
  /// Same contract as SwiftUI's `move(fromOffsets:toOffset:)`: the destination is an offset into the list before anything is removed.
  /// Written out here so TodayKit never imports SwiftUI.
  public static func moving(_ items: [TodayItem], fromOffsets source: IndexSet, toOffset destination: Int) -> [TodayItem] {
    let moving = source.sorted().map { items[$0] }
    var remaining: [TodayItem] = []
    for (index, item) in items.enumerated() where !source.contains(index) {
      remaining.append(item)
    }
    let insertionIndex = destination - source.filter { $0 < destination }.count
    remaining.insert(contentsOf: moving, at: insertionIndex)
    return reassigningOrders(remaining)
  }
}
