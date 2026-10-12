/// The three states the circle can show.
public enum CheckState: Hashable, Sendable, CaseIterable {
  case todo
  case doing
  case done

  /// The state a click moves to, stopping at done.
  public var next: Self {
    switch self {
    case .todo: .doing
    case .doing, .done: .done
    }
  }

  /// The state an option-click moves to, stopping at to do.
  public var previous: Self {
    switch self {
    case .todo, .doing: .todo
    case .done: .doing
    }
  }

  public var label: String {
    switch self {
    case .todo: "To Do"
    case .doing: "In Progress"
    case .done: "Done"
    }
  }

  public var symbol: String {
    switch self {
    case .todo: "circle"
    case .doing: "circle.lefthalf.filled"
    case .done: "checkmark.circle.fill"
    }
  }
}
