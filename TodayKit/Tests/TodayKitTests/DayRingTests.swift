import Foundation
import Testing
import TodayKit

@Suite struct DayRingTests {
  let calendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "America/Los_Angeles")!
    return calendar
  }()
  let endOfDay = EndOfDay(hour: 4)
  let day = LogicalDay(year: 2026, month: 10, day: 11)

  func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int) -> Date {
    calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
  }

  func item(_ id: String, days: [LogicalDay], completedAt: Date? = nil) -> TodayItem {
    TodayItem(
      id: id, title: id, bucket: .today, isCompleted: completedAt != nil, completionDate: completedAt,
      metadata: ItemMetadata(days: days))
  }

  @Test func emptyDayIsGray() {
    let ring = DayRing.compute(day: day, items: [], endOfDay: endOfDay, calendar: calendar)
    #expect(ring.outcome == .empty)
    #expect(ring.completedFraction == 0)
  }

  @Test func countsOnlyItemsThatWereOnTheListThatDay() {
    let items = [
      item("a", days: [day], completedAt: date(2026, 10, 11, 15)),
      item("b", days: [day]),
      item("c", days: [day.advanced(by: -1)], completedAt: date(2026, 10, 11, 15)),
    ]
    let ring = DayRing.compute(day: day, items: items, endOfDay: endOfDay, calendar: calendar)
    #expect(ring.total == 2)
    #expect(ring.completed == 1)
    #expect(ring.outcome == .someDone)
    #expect(ring.completedFraction == 0.5)
  }

  @Test func completionAfterEndOfDayDoesNotCount() {
    let items = [item("a", days: [day], completedAt: date(2026, 10, 12, 5))]
    let ring = DayRing.compute(day: day, items: items, endOfDay: endOfDay, calendar: calendar)
    #expect(ring.outcome == .noneDone)
  }

  @Test func completionAtTwoInTheMorningStillCounts() {
    let items = [item("a", days: [day], completedAt: date(2026, 10, 12, 2))]
    let ring = DayRing.compute(day: day, items: items, endOfDay: endOfDay, calendar: calendar)
    #expect(ring.outcome == .allDone)
  }

  @Test func rangeProducesOneRingPerDayOldestFirst() {
    let first = day.advanced(by: -2, calendar: calendar)
    let rings = DayRing.computeRange(from: first, through: day, items: [], endOfDay: endOfDay, calendar: calendar)
    #expect(rings.map(\.day) == [first, first.advanced(by: 1, calendar: calendar), day])
  }
}
