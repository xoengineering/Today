import SwiftUI

struct ContentView: View {
  @Environment(RemindersStore.self) private var store
  @Environment(NavigationState.self) private var navigation

  var body: some View {
    @Bindable var navigation = navigation
    Group {
      if store.hasAccess {
        NavigationSplitView {
          SidebarView(selection: $navigation.screen)
            // One fixed width. Three entries don't need a resizable column, only a toggle.
            .navigationSplitViewColumnWidth(200)
        } detail: {
          switch navigation.screen {
          case .today, .none: TodayListView()
          case .backlog: BacklogListView()
          case .rings: RingsView()
          }
        }
      } else {
        AccessView()
      }
    }
    .environment(\.textScale, store.settings.textSize.scale)
    .environment(\.fontTheme, store.settings.fontTheme)
    #if os(macOS)
      // The sidebar plus 360 for content. The content has no minimum of its own, so nothing is ever clipped.
      .frame(minWidth: 560, minHeight: 320)
    #endif
    .task {
      if store.authorization == .notDetermined {
        await store.requestAccess()
      } else {
        await store.start()
      }
    }
  }
}
