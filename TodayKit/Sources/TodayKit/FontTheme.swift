/// Which of the system's four typeface designs the app's text uses.
public enum FontTheme: String, Codable, CaseIterable, Hashable, Sendable {
  case sans
  case rounded
  case serif
  case mono

  public var label: String {
    switch self {
    case .mono: "Mono"
    case .rounded: "Rounded"
    case .sans: "Sans"
    case .serif: "Serif"
    }
  }
}
