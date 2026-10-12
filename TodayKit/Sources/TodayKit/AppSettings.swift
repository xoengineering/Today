/// Everything the user can configure, shared by the app and the widget.
public struct AppSettings: Codable, Hashable, Sendable {
  public var endOfDay: EndOfDay
  /// The `calendarIdentifier` of the Today list on this device, once resolved.
  public var todayListIdentifier: String?
  /// The `calendarIdentifier` of the Backlog list on this device, once resolved.
  public var backlogListIdentifier: String?

  public init(endOfDay: EndOfDay = .default, todayListIdentifier: String? = nil, backlogListIdentifier: String? = nil) {
    self.endOfDay = endOfDay
    self.todayListIdentifier = todayListIdentifier
    self.backlogListIdentifier = backlogListIdentifier
  }
}
