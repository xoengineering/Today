/// How big the app's text is, in five steps where Medium is the system's own size.
public enum TextSize: String, Codable, CaseIterable, Hashable, Sendable {
  case small
  case medium
  case large
  case extraLarge
  case huge

  public var label: String {
    switch self {
    case .extraLarge: "Extra Large"
    case .huge: "Huge"
    case .large: "Large"
    case .medium: "Medium"
    case .small: "Small"
    }
  }

  /// The next step up, or this one at the top.
  public var bigger: Self {
    let all = Self.allCases
    let index = all.firstIndex(of: self) ?? 0
    return all[min(index + 1, all.count - 1)]
  }

  /// The next step down, or this one at the bottom.
  public var smaller: Self {
    let all = Self.allCases
    let index = all.firstIndex(of: self) ?? 0
    return all[max(index - 1, 0)]
  }
}
