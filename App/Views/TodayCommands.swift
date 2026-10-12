import SwiftUI

/// The menu bar on macOS, and the same key equivalents everywhere.
struct TodayCommands: Commands {
  let navigation: NavigationState
  let store: RemindersStore

  var body: some Commands {
    CommandGroup(replacing: .newItem) {
      Button("New Item") { navigation.requestAddItem() }
        .keyboardShortcut("n")
    }
    CommandGroup(after: .toolbar) {
      Button("Bigger Text") { store.settings.textSize = store.settings.textSize.bigger }
        .keyboardShortcut("+")
      Button("Smaller Text") { store.settings.textSize = store.settings.textSize.smaller }
        .keyboardShortcut("-")
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
