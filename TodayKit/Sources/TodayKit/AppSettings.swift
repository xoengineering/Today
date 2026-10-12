/// Everything the user can configure, shared by the app and the widget.
public struct AppSettings: Codable, Hashable, Sendable {
  public var endOfDay: EndOfDay
  public var dateFormat: DateFormatChoice
  /// The `calendarIdentifier` of the Today list on this device, once resolved.
  public var todayListIdentifier: String?
  /// The `calendarIdentifier` of the Backlog list on this device, once resolved.
  public var backlogListIdentifier: String?

  public init(
    endOfDay: EndOfDay = .default,
    dateFormat: DateFormatChoice = .system,
    todayListIdentifier: String? = nil,
    backlogListIdentifier: String? = nil
  ) {
    self.endOfDay = endOfDay
    self.dateFormat = dateFormat
    self.todayListIdentifier = todayListIdentifier
    self.backlogListIdentifier = backlogListIdentifier
  }

  enum CodingKeys: String, CodingKey {
    case backlogListIdentifier
    case dateFormat
    case endOfDay
    case todayListIdentifier
  }

  /// Settings saved before a key existed decode with that key's default, so adding a setting never resets the rest.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    endOfDay = try container.decodeIfPresent(EndOfDay.self, forKey: .endOfDay) ?? .default
    dateFormat = try container.decodeIfPresent(DateFormatChoice.self, forKey: .dateFormat) ?? .system
    todayListIdentifier = try container.decodeIfPresent(String.self, forKey: .todayListIdentifier)
    backlogListIdentifier = try container.decodeIfPresent(String.self, forKey: .backlogListIdentifier)
  }
}
