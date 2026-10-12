/// The two states an incomplete item can be in.
///
/// Done is a real Reminders completion, not a state here.
public enum ItemState: String, Codable, Sendable {
  case doing
  case todo
}
