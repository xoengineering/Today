import Foundation
import Testing
import TodayKit

@Suite struct LogicalDayTests {
  let calendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "America/Los_Angeles")!
    return calendar
  }()

  func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
    calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
  }

  @Test func twoInTheMorningBelongsToTheNightBefore() {
    let day = LogicalDay(containing: date(2026, 10, 12, 2), endOfDay: EndOfDay(hour: 4), calendar: calendar)
    #expect(day == LogicalDay(year: 2026, month: 10, day: 11))
  }

  @Test func fourInTheMorningStartsTheNewDay() {
    let day = LogicalDay(containing: date(2026, 10, 12, 4), endOfDay: EndOfDay(hour: 4), calendar: calendar)
    #expect(day == LogicalDay(year: 2026, month: 10, day: 12))
  }

  @Test func midnightEndOfDayMatchesTheCalendar() {
    let day = LogicalDay(containing: date(2026, 10, 12, 0, 30), endOfDay: EndOfDay(hour: 0), calendar: calendar)
    #expect(day == LogicalDay(year: 2026, month: 10, day: 12))
  }

  @Test func intervalRunsFromEndOfDayToEndOfDay() {
    let day = LogicalDay(year: 2026, month: 10, day: 11)
    let interval = day.interval(endOfDay: EndOfDay(hour: 4), calendar: calendar)
    #expect(interval.start == date(2026, 10, 11, 4))
    #expect(interval.end == date(2026, 10, 12, 4))
  }

  @Test func intervalSurvivesDaylightSavingTransitions() {
    // Clocks fall back at 02:00 on 2026-11-01 in Los Angeles. With a 04:00 end of day that hour lands in the logical day
    // that starts on 10-31, which is 25 hours long.
    let day = LogicalDay(year: 2026, month: 10, day: 31)
    let interval = day.interval(endOfDay: EndOfDay(hour: 4), calendar: calendar)
    #expect(interval.start == date(2026, 10, 31, 4))
    #expect(interval.end == date(2026, 11, 1, 4))
    #expect(interval.duration == 25 * 60 * 60)
  }

  @Test func advancingCrossesMonthAndYearBoundaries() {
    #expect(
      LogicalDay(year: 2026, month: 12, day: 31).advanced(by: 1, calendar: calendar)
        == LogicalDay(year: 2027, month: 1, day: 1))
    #expect(
      LogicalDay(year: 2026, month: 3, day: 1).advanced(by: -1, calendar: calendar)
        == LogicalDay(year: 2026, month: 2, day: 28))
  }

  @Test func advancingByAYearLandsOnTheSameDate() {
    #expect(
      LogicalDay(year: 2026, month: 10, day: 11).advanced(by: -1, .year, calendar: calendar)
        == LogicalDay(year: 2025, month: 10, day: 11))
    // 2024 is a leap year. Its February 29 has no twin a year later, so the calendar clamps.
    #expect(
      LogicalDay(year: 2024, month: 2, day: 29).advanced(by: 1, .year, calendar: calendar)
        == LogicalDay(year: 2025, month: 2, day: 28))
  }

  @Test func comparesChronologically() {
    #expect(LogicalDay(year: 2026, month: 1, day: 31) < LogicalDay(year: 2026, month: 2, day: 1))
    #expect(LogicalDay(year: 2025, month: 12, day: 31) < LogicalDay(year: 2026, month: 1, day: 1))
  }

  @Test func spellsAndParsesPaddedDates() {
    let day = LogicalDay(year: 2026, month: 3, day: 7)
    #expect(day.description == "2026-03-07")
    #expect(LogicalDay("2026-03-07") == day)
    #expect(LogicalDay("2026-3-7") == day)
    #expect(LogicalDay("yesterday") == nil)
    #expect(LogicalDay("2026-13-01") == nil)
  }

  @Test func codesAsAString() throws {
    let encoded = try JSONEncoder().encode([LogicalDay(year: 2026, month: 10, day: 11)])
    #expect(String(bytes: encoded, encoding: .utf8) == "[\"2026-10-11\"]")
    let decoded = try JSONDecoder().decode([LogicalDay].self, from: encoded)
    #expect(decoded == [LogicalDay(year: 2026, month: 10, day: 11)])
  }
}
