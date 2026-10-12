/// The wall-clock time at which one logical day ends and the next begins.
///
/// Midnight is not the end of a night owl's day. Four in the morning is.
public struct EndOfDay: Codable, Hashable, Sendable {
  public static let `default` = Self(hour: 4, minute: 0)

  public var hour: Int
  public var minute: Int

  public init(hour: Int, minute: Int = 0) {
    self.hour = hour
    self.minute = minute
  }
}
