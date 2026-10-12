import SwiftUI
import TodayKit

extension TextSize {
  /// How much bigger than the system's own size each step is, with Medium being the system size.
  var scale: Double {
    switch self {
    case .extraLarge: 1.3
    case .huge: 1.5
    case .large: 1.15
    case .medium: 1
    case .small: 0.9
    }
  }
}

/// The current text scale, set once at the window root from the text size setting.
///
/// macOS has no Dynamic Type, so the app scales its own fonts and metrics by this number.
extension EnvironmentValues {
  @Entry var textScale: Double = 1
}
