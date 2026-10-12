import Foundation
import Testing
import TodayKit

@Suite struct TodayOrderingTests {
  func item(_ id: String, order: Int? = nil, created: TimeInterval? = nil) -> TodayItem {
    TodayItem(
      id: id, title: id, bucket: .today,
      creationDate: created.map { Date(timeIntervalSince1970: $0) },
      metadata: order.map { ItemMetadata(order: $0) })
  }

  @Test func sortsByOrderThenCreationThenTitle() {
    let items = [item("d"), item("c", created: 2), item("b", created: 1), item("a", order: 1), item("z", order: 0)]
    #expect(TodayOrdering.sorted(items).map(\.id) == ["z", "a", "b", "c", "d"])
  }

  @Test func reassigningOrdersMakesThemDense() {
    let items = [item("a", order: 10), item("b"), item("c", order: 10)]
    #expect(TodayOrdering.reassigningOrders(items).map(\.order) == [0, 1, 2])
  }

  @Test func movingMirrorsSwiftUIDrag() {
    let items = TodayOrdering.reassigningOrders([item("a"), item("b"), item("c")])
    let moved = TodayOrdering.moving(items, fromOffsets: IndexSet(integer: 2), toOffset: 0)
    #expect(moved.map(\.id) == ["c", "a", "b"])
    #expect(moved.map(\.order) == [0, 1, 2])
  }

  @Test func movingToTheEndUsesTheOffsetBeforeRemoval() {
    let items = TodayOrdering.reassigningOrders([item("a"), item("b"), item("c")])
    let moved = TodayOrdering.moving(items, fromOffsets: IndexSet(integer: 0), toOffset: 3)
    #expect(moved.map(\.id) == ["b", "c", "a"])
  }
}
