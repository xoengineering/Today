import Foundation

/// How a day is written on the Rings screen.
public enum DateFormatChoice: String, Codable, CaseIterable, Hashable, Sendable {
  /// The locale's own medium date, which is what the system shows almost everywhere.
  case system
  case iso8601
  /// The month spelled out: October 11, 2026.
  case long
  /// The weekday and the month spelled out: Saturday, October 11, 2026.
  case complete
  /// Digits only, in the locale's order: 10/11/2026.
  case numeric

  public var label: String {
    switch self {
    case .complete: "Weekday and long"
    case .iso8601: "ISO 8601"
    case .long: "Long"
    case .numeric: "Numeric"
    case .system: "System"
    }
  }

  public func format(_ day: LogicalDay, calendar: Calendar = .current, locale: Locale = .current) -> String {
    if self == .iso8601 {
      return day.description
    }
    let date = calendar.date(from: DateComponents(year: day.year, month: day.month, day: day.day)) ?? .distantPast
    var style = Date.FormatStyle(date: dateStyle, time: .omitted, locale: locale, calendar: calendar)
    style.timeZone = calendar.timeZone
    return date.formatted(style)
  }

  private var dateStyle: Date.FormatStyle.DateStyle {
    switch self {
    case .complete: .complete
    case .iso8601, .numeric: .numeric
    case .long: .long
    case .system: .abbreviated
    }
  }
}
