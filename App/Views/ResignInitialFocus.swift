import SwiftUI

#if os(macOS)
  import AppKit

  /// Stops a window from handing keyboard focus to its first control when it opens.
  ///
  /// SwiftUI's focus state cannot reach AppKit-backed controls such as a date stepper, so this asks the window itself.
  /// Tab still reaches every control afterward.
  struct ResignInitialFocus: ViewModifier {
    func body(content: Content) -> some View {
      content.onAppear {
        // The window is not key yet during onAppear. The next turn of the run loop, it is.
        Task { @MainActor in
          NSApp.keyWindow?.makeFirstResponder(nil)
        }
      }
    }
  }
#endif

extension View {
  func resignInitialFocus() -> some View {
    #if os(macOS)
      modifier(ResignInitialFocus())
    #else
      self
    #endif
  }
}
