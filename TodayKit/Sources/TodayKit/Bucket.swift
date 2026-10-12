/// The only two places an item can be.
public enum Bucket: String, Codable, Hashable, Sendable {
  case backlog
  case today
}
