import SwiftUI

/// The menu bar on macOS, and the same key equivalents everywhere.
///
/// Every item carries a symbol. Menus drop them unless the label style asks for both.
struct TodayCommands: Commands {
  let navigation: NavigationState
  let store: RemindersStore

  var body: some Commands {
    CommandGroup(replacing: .newItem) {
      NewItemButton(navigation: navigation)
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
    CommandGroup(after: .windowArrangement) {
      ShowWindowButton()
        .keyboardShortcut("0")
        .labelStyle(.titleAndIcon)
    }
    SidebarCommands()
  }
}

/// Shows the window, which may have been closed, goes to Today, and puts the cursor in the add field.
private struct NewItemButton: View {
  @Environment(\.openWindow) private var openWindow
  let navigation: NavigationState

  var body: some View {
    Button("New Item", systemImage: "plus") {
      openWindow(id: "main")
      navigation.requestAddItem()
    }
  }
}

/// Brings the one window back after it has been closed.
private struct ShowWindowButton: View {
  @Environment(\.openWindow) private var openWindow

  var body: some View {
    Button("Today", systemImage: "macwindow") {
      openWindow(id: "main")
    }
  }
}
