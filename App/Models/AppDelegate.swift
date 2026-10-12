#if os(macOS)
  import AppKit

  /// Keeps the app running when its one window is closed, so ⌘0 and ⌘N can bring the window back.
  ///
  /// A `Window` scene quits the app with its last window unless the delegate says otherwise.
  final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
      false
    }
  }
#endif
