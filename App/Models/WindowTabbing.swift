#if os(macOS)
  import AppKit

  /// Turns window tabbing off, since Today has one window and the View menu should not offer tabs for it.
  ///
  /// SwiftUI has no switch for this, so it is the one AppKit call at launch.
  enum WindowTabbing {
    @MainActor
    static func disable() {
      NSWindow.allowsAutomaticWindowTabbing = false
    }
  }
#endif
