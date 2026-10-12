import Testing
import TodayKit

@Suite struct DayRolloverTests {
  let yesterday = LogicalDay(year: 2026, month: 10, day: 10)
  let today = LogicalDay(year: 2026, month: 10, day: 11)

  @Test func backlogItemsAreLeftAlone() {
    let item = TodayItem(id: "a", title: "A", bucket: .backlog)
    #expect(DayRollover.action(for: item, today: today) == .keep)
  }

  @Test func todayItemsWithNoHistoryAreAdopted() {
    let item = TodayItem(id: "a", title: "A", bucket: .today)
    #expect(DayRollover.action(for: item, today: today) == .adopt)
    let emptyDays = TodayItem(id: "b", title: "B", bucket: .today, metadata: ItemMetadata())
    #expect(DayRollover.action(for: emptyDays, today: today) == .adopt)
  }

  @Test func unfinishedItemsFromEarlierDaysGoBack() {
    let item = TodayItem(
      id: "a", title: "A", bucket: .today, metadata: ItemMetadata(order: 0, state: .doing, days: [yesterday]))
    #expect(DayRollover.action(for: item, today: today) == .returnToBacklog)
  }

  @Test func finishedItemsFromEarlierDaysStay() {
    let item = TodayItem(id: "a", title: "A", bucket: .today, isCompleted: true, metadata: ItemMetadata(days: [yesterday]))
    #expect(DayRollover.action(for: item, today: today) == .keep)
  }

  @Test func itemsFromTodayOrLaterStay() {
    let item = TodayItem(id: "a", title: "A", bucket: .today, metadata: ItemMetadata(days: [today]))
    #expect(DayRollover.action(for: item, today: today) == .keep)
    let future = TodayItem(id: "b", title: "B", bucket: .today, metadata: ItemMetadata(days: [today.advanced(by: 1)]))
    #expect(DayRollover.action(for: future, today: today) == .keep)
  }

  @Test func applyMovesReturnsAndAdoptsInOnePass() {
    let items = [
      TodayItem(
        id: "stale", title: "Stale", bucket: .today, metadata: ItemMetadata(order: 0, state: .doing, days: [yesterday])),
      TodayItem(id: "fresh", title: "Fresh", bucket: .today, metadata: ItemMetadata(order: 1, days: [today])),
      TodayItem(id: "new", title: "New", bucket: .today),
      TodayItem(id: "later", title: "Later", bucket: .backlog),
    ]
    let applied = DayRollover.apply(to: items, today: today)
    #expect(applied.map(\.bucket) == [.backlog, .today, .today, .backlog])
    #expect(applied[0].order == nil)
    #expect(applied[0].checkState == .todo)
    #expect(applied[2].metadata?.days == [today])
    #expect(applied[2].order == 2)
  }
}
