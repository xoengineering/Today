/// The three states the circle can show.
public enum CheckState: Hashable, Sendable, CaseIterable {
  case todo
  case doing
  case done

  /// The state a tap moves to, round and round.
  public var next: Self {
    switch self {
    case .todo: .doing
    case .doing: .done
    case .done: .todo
    }
  }
}
