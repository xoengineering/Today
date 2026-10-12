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
          Group {
            switch navigation.screen {
            case .today, .none: TodayListView()
            case .backlog: BacklogListView()
            case .rings: RingsView()
            }
          }
          #if os(macOS)
            .frame(minWidth: 400)
          #endif
        }
      } else {
        AccessView()
      }
    }
    #if os(macOS)
      .frame(minWidth: 480, minHeight: 320)
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
