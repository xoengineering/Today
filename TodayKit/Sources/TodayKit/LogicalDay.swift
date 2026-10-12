import Foundation

/// A day as the user experiences it, bounded by their end of day rather than by midnight.
///
/// Named by the calendar date on which it starts, so the day that runs from 2026-10-11 04:00 to 2026-10-12 04:00 is 2026-10-11.
public struct LogicalDay: Hashable, Comparable, Sendable, CustomStringConvertible {
  public let year: Int
  public let month: Int
  public let day: Int

  public init(year: Int, month: Int, day: Int) {
    self.year = year
    self.month = month
    self.day = day
  }

  /// The logical day containing an instant.
  public init(containing date: Date, endOfDay: EndOfDay, calendar: Calendar = .current) {
    // Shifting the instant back by the end-of-day offset turns the question into a plain calendar lookup.
    let shifted = calendar.date(byAdding: .minute, value: -(endOfDay.hour * 60 + endOfDay.minute), to: date) ?? date
    let components = calendar.dateComponents([.year, .month, .day], from: shifted)
    self.init(year: components.year ?? 0, month: components.month ?? 0, day: components.day ?? 0)
  }

  /// Parses the `YYYY-MM-DD` spelling used in the notes footer.
  public init?(_ string: String) {
    let parts = string.split(separator: "-", omittingEmptySubsequences: false)
    guard parts.count == 3,
      let year = Int(parts[0]), let month = Int(parts[1]), let day = Int(parts[2]),
      (1...12).contains(month), (1...31).contains(day)
    else { return nil }
    self.init(year: year, month: month, day: day)
  }

  /// The instants this logical day spans.
  public func interval(endOfDay: EndOfDay, calendar: Calendar = .current) -> DateInterval {
    let startComponents = DateComponents(year: year, month: month, day: day, hour: endOfDay.hour, minute: endOfDay.minute)
    let start = calendar.date(from: startComponents) ?? .distantPast
    let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start
    return DateInterval(start: start, end: end)
  }

  public func advanced(by days: Int, calendar: Calendar = .current) -> Self {
    advanced(by: days, .day, calendar: calendar)
  }

  /// The day this many calendar units away, so a year back lands on the same date, leap years included.
  public func advanced(by value: Int, _ component: Calendar.Component, calendar: Calendar = .current) -> Self {
    let start = calendar.date(from: DateComponents(year: year, month: month, day: day)) ?? .distantPast
    let shifted = calendar.date(byAdding: component, value: value, to: start) ?? start
    let components = calendar.dateComponents([.year, .month, .day], from: shifted)
    return Self(year: components.year ?? year, month: components.month ?? month, day: components.day ?? day)
  }

  public var description: String {
    let paddedMonth = month < 10 ? "0\(month)" : "\(month)"
    let paddedDay = day < 10 ? "0\(day)" : "\(day)"
    return "\(year)-\(paddedMonth)-\(paddedDay)"
  }

  public static func < (lhs: Self, rhs: Self) -> Bool {
    (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
  }
}

extension LogicalDay: Codable {
  public init(from decoder: Decoder) throws {
    let string = try decoder.singleValueContainer().decode(String.self)
    guard let day = LogicalDay(string) else {
      throw DecodingError.dataCorrupted(
        DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Not a YYYY-MM-DD day: \(string)"))
    }
    self = day
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(description)
  }
}
