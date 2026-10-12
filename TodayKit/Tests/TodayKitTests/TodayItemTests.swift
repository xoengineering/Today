import Foundation
import Testing
import TodayKit

@Suite struct TodayItemTests {
  let day = LogicalDay(year: 2026, month: 10, day: 11)

  @Test func checkStateDerivesFromCompletionThenMetadata() {
    let plain = TodayItem(id: "a", title: "A", bucket: .backlog)
    #expect(plain.checkState == .todo)
    let doing = TodayItem(id: "b", title: "B", bucket: .today, metadata: ItemMetadata(state: .doing))
    #expect(doing.checkState == .doing)
    let done = TodayItem(id: "c", title: "C", bucket: .today, isCompleted: true, metadata: ItemMetadata(state: .doing))
    #expect(done.checkState == .done)
  }

  @Test func settingDoneCompletesTheReminder() {
    let now = Date(timeIntervalSince1970: 1_000_000)
    let item = TodayItem(id: "a", title: "A", bucket: .today, metadata: ItemMetadata(state: .doing)).setting(
      .done, completedAt: now)
    #expect(item.isCompleted)
    #expect(item.completionDate == now)
    #expect(item.metadata?.state == .todo)
  }

  @Test func settingTodoFromDoneUncompletes() {
    let item = TodayItem(id: "a", title: "A", bucket: .today, isCompleted: true, completionDate: .now).setting(.todo)
    #expect(!item.isCompleted)
    #expect(item.completionDate == nil)
    #expect(item.checkState == .todo)
  }

  @Test func movingToTodayRecordsTheDayOnce() {
    let item = TodayItem(id: "a", title: "A", bucket: .backlog)
      .movedToToday(on: day, order: 2)
      .movedToToday(on: day, order: 5)
    #expect(item.bucket == .today)
    #expect(item.metadata?.days == [day])
    #expect(item.order == 5)
  }

  @Test func movingToTodayOnALaterDayAppends() {
    let later = day.advanced(by: 1)
    let item = TodayItem(id: "a", title: "A", bucket: .backlog).movedToToday(on: day, order: 0).movedToBacklog()
      .movedToToday(on: later, order: 0)
    #expect(item.metadata?.days == [day, later])
  }

  @Test func movingToBacklogKeepsHistoryDropsOrderAndProgress() {
    let item = TodayItem(id: "a", title: "A", bucket: .today, metadata: ItemMetadata(order: 1, state: .doing, days: [day]))
      .movedToBacklog()
    #expect(item.bucket == .backlog)
    #expect(item.metadata?.days == [day])
    #expect(item.order == nil)
    #expect(item.checkState == .todo)
  }
}
