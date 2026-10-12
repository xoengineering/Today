import Foundation
import Testing
import TodayKit

@Suite struct RingCalendarTests {
  func calendar(firstWeekday: Int) -> Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "America/Los_Angeles")!
    calendar.firstWeekday = firstWeekday
    return calendar
  }

  // 2026-10-11 is a Sunday.
  let sunday = LogicalDay(year: 2026, month: 10, day: 11)

  @Test func weekStartsOnSundayForSundayFirstCalendars() {
    let calendar = calendar(firstWeekday: 1)
    #expect(RingCalendar.startOfWeek(containing: sunday, calendar: calendar) == sunday)
    #expect(RingCalendar.startOfWeek(containing: sunday.advanced(by: 3, calendar: calendar), calendar: calendar) == sunday)
  }

  @Test func weekStartsOnMondayForMondayFirstCalendars() {
    let calendar = calendar(firstWeekday: 2)
    let monday = LogicalDay(year: 2026, month: 10, day: 5)
    #expect(RingCalendar.startOfWeek(containing: sunday, calendar: calendar) == monday)
  }

  @Test func daysCoverWholeWeeksEndingWithTheCurrentOne() {
    let calendar = calendar(firstWeekday: 1)
    let days = RingCalendar.days(endingOn: sunday.advanced(by: 2, calendar: calendar), weeks: 2, calendar: calendar)
    #expect(days.count == 14)
    #expect(days.first == LogicalDay(year: 2026, month: 10, day: 4))
    #expect(days.last == LogicalDay(year: 2026, month: 10, day: 17))
  }

  @Test func weekdaySymbolsRotateToTheFirstWeekday() {
    #expect(RingCalendar.weekdaySymbols(calendar: calendar(firstWeekday: 2)).first == "M")
    #expect(RingCalendar.weekdaySymbols(calendar: calendar(firstWeekday: 1)).first == "S")
  }
}
