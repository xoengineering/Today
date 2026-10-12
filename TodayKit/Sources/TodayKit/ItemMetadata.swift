/// What Today stores about a reminder, in the footer line of its notes.
///
/// Reminders has no custom fields, so this is the only per-item state the app owns.
public struct ItemMetadata: Codable, Hashable, Sendable {
  public static let currentVersion = 1

  /// The footer format version, so a future format can read old footers.
  public var version: Int
  /// Position in the Today list, meaningful only while the item is there.
  public var order: Int?
  public var state: ItemState
  /// Every logical day this item sat on the Today list, which is the ring history.
  public var days: [LogicalDay]

  public init(order: Int? = nil, state: ItemState = .todo, days: [LogicalDay] = []) {
    self.version = Self.currentVersion
    self.order = order
    self.state = state
    self.days = days
  }

  enum CodingKeys: String, CodingKey {
    case days
    case order
    case state
    case version = "v"
  }
}
