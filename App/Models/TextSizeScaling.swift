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

extension FontTheme {
  /// The system typeface design behind each theme.
  var design: Font.Design {
    switch self {
    case .mono: .monospaced
    case .rounded: .rounded
    case .sans: .default
    case .serif: .serif
    }
  }
}

/// The current text scale and typeface, set once at the window root from the settings.
///
/// macOS has no Dynamic Type, so the app scales its own fonts and metrics by this number.
extension EnvironmentValues {
  @Entry var textScale: Double = 1
  @Entry var fontTheme: FontTheme = .sans
}
