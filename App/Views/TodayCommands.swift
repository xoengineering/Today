import SwiftUI

/// The menu bar on macOS, and the same key equivalents everywhere.
///
/// Every item carries a symbol. Menus drop them unless the label style asks for both.
struct TodayCommands: Commands {
  let navigation: NavigationState
  let store: RemindersStore

  var body: some Commands {
    CommandGroup(replacing: .newItem) {
      Button("New Item", systemImage: "plus") { navigation.requestAddItem() }
        .keyboardShortcut("n")
        .labelStyle(.titleAndIcon)
    }
    CommandGroup(after: .toolbar) {
      Button("Bigger Text", systemImage: "textformat.size.larger") {
        store.settings.textSize = store.settings.textSize.bigger
      }
      .keyboardShortcut("+")
      .labelStyle(.titleAndIcon)
      Button("Smaller Text", systemImage: "textformat.size.smaller") {
        store.settings.textSize = store.settings.textSize.smaller
      }
      .keyboardShortcut("-")
      .labelStyle(.titleAndIcon)
    }
    CommandMenu("Go") {
      ForEach(Screen.allCases) { screen in
        Button(screen.title, systemImage: screen.symbol) { navigation.screen = screen }
          .keyboardShortcut(screen.shortcut)
          .labelStyle(.titleAndIcon)
      }
    }
    SidebarCommands()
  }
}
