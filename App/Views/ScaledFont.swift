import SwiftUI
import TodayKit

/// A text style at the current text scale.
///
/// The base sizes are the platform's own for each style, so at scale 1 this is exactly `.font(style)`.
struct ScaledFont: ViewModifier {
  @Environment(\.textScale) private var textScale
  @Environment(\.fontTheme) private var fontTheme
  let style: Font.TextStyle
  let weight: Font.Weight?

  func body(content: Content) -> some View {
    content.font(
      .system(
        size: Self.baseSize(of: style) * textScale, weight: weight ?? Self.baseWeight(of: style), design: fontTheme.design))
  }

  #if os(macOS)
    private static let baseSizes: [Font.TextStyle: Double] = [
      .largeTitle: 26, .title: 22, .title2: 17, .title3: 15, .headline: 13, .body: 13,
      .callout: 12, .subheadline: 11, .footnote: 10, .caption: 10, .caption2: 10,
    ]
  #else
    private static let baseSizes: [Font.TextStyle: Double] = [
      .largeTitle: 34, .title: 28, .title2: 22, .title3: 20, .headline: 17, .body: 17,
      .callout: 16, .subheadline: 15, .footnote: 13, .caption: 12, .caption2: 11,
    ]
  #endif

  static func baseSize(of style: Font.TextStyle) -> Double {
    baseSizes[style] ?? baseSizes[.body] ?? 13
  }

  static func baseWeight(of style: Font.TextStyle) -> Font.Weight {
    style == .headline ? .semibold : .regular
  }
}

extension View {
  func scaledFont(_ style: Font.TextStyle, weight: Font.Weight? = nil) -> some View {
    modifier(ScaledFont(style: style, weight: weight))
  }
}
