import SwiftUI

struct ContentView: View {
  @Environment(RemindersStore.self) private var store
  @State private var selection: Screen? = .today

  var body: some View {
    Group {
      if store.hasAccess {
        NavigationSplitView {
          SidebarView(selection: $selection)
        } detail: {
          switch selection {
          case .today, .none: TodayListView()
          case .backlog: BacklogListView()
          case .rings: RingsView()
          }
        }
      } else {
        AccessView()
      }
    }
    .frame(minWidth: 480, minHeight: 320)
    .task {
      if store.authorization == .notDetermined {
        await store.requestAccess()
      } else {
        await store.start()
      }
    }
  }
}
