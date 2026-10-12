import SwiftUI

@main
struct TodayApp: App {
  @State private var store = RemindersStore()
  @State private var navigation = NavigationState()
  #if os(macOS)
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
  #endif

  init() {
    #if os(macOS)
      WindowTabbing.disable()
    #endif
  }

  var body: some Scene {
    #if os(macOS)
      // One window, which the Window menu and ⌘N can bring back after it is closed.
      Window("Today", id: "main") {
        ContentView()
          .environment(store)
          .environment(navigation)
      }
      .commands {
        TodayCommands(navigation: navigation, store: store)
      }

      Settings {
        SettingsView()
          .environment(store)
          .frame(width: 420)
      }
    #else
      WindowGroup {
        ContentView()
          .environment(store)
          .environment(navigation)
      }
      .commands {
        TodayCommands(navigation: navigation, store: store)
      }
    #endif
  }
}
