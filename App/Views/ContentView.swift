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
            .navigationSplitViewColumnWidth(min: 160, ideal: 200, max: 280)
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
    #if os(macOS)
      // The sidebar's widest plus 320 for content. The content has no minimum of its own, so nothing is ever clipped.
      .frame(minWidth: 600, minHeight: 320)
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
