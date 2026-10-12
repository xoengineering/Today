import Foundation

/// The grid of days the rings screen shows: whole weeks, ending with the current week.
public enum RingCalendar {
  /// Every day in the `weeks` weeks ending with the week that contains `last`, oldest first, aligned to the calendar's first weekday.
  public static func days(endingOn last: LogicalDay, weeks: Int, calendar: Calendar = .current) -> [LogicalDay] {
    let lastWeekStart = startOfWeek(containing: last, calendar: calendar)
    let first = lastWeekStart.advanced(by: -7 * (weeks - 1), calendar: calendar)
    return (0..<(weeks * 7)).map { first.advanced(by: $0, calendar: calendar) }
  }

  /// The first day of the week containing `day`, by the calendar's `firstWeekday`.
  public static func startOfWeek(containing day: LogicalDay, calendar: Calendar = .current) -> LogicalDay {
    let date = calendar.date(from: DateComponents(year: day.year, month: day.month, day: day.day)) ?? .distantPast
    let weekday = calendar.component(.weekday, from: date)
    let offset = (weekday - calendar.firstWeekday + 7) % 7
    return day.advanced(by: -offset, calendar: calendar)
  }

  /// Weekday symbols in grid order, starting from the calendar's first weekday.
  public static func weekdaySymbols(calendar: Calendar = .current) -> [String] {
    let symbols = calendar.veryShortWeekdaySymbols
    let start = calendar.firstWeekday - 1
    return Array(symbols[start...] + symbols[..<start])
  }
}
