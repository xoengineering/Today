import SwiftUI

/// The menu bar on macOS, and the same key equivalents everywhere.
struct TodayCommands: Commands {
  let navigation: NavigationState

  var body: some Commands {
    CommandGroup(replacing: .newItem) {
      Button("New Item") { navigation.requestAddItem() }
        .keyboardShortcut("n")
    }
    CommandMenu("Go") {
      Button("Today") { navigation.screen = .today }
        .keyboardShortcut("1")
      Button("Backlog") { navigation.screen = .backlog }
        .keyboardShortcut("2")
      Button("Rings") { navigation.screen = .rings }
        .keyboardShortcut("3")
    }
    SidebarCommands()
  }
}
