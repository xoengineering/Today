import SwiftUI

@main
struct TodayApp: App {
  @State private var store = RemindersStore()
  @State private var navigation = NavigationState()

  init() {
    #if os(macOS)
      WindowTabbing.disable()
    #endif
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(store)
        .environment(navigation)
    }
    .commands {
      TodayCommands(navigation: navigation)
    }

    #if os(macOS)
      Settings {
        SettingsView()
          .environment(store)
          .frame(width: 420)
      }
    #endif
  }
}
