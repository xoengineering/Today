import SwiftUI

struct ContentView: View {
  @Environment(RemindersStore.self) private var store
  @Environment(NavigationState.self) private var navigation
  @State private var isShowingSettings = false

  var body: some View {
    @Bindable var navigation = navigation
    Group {
      if store.hasAccess {
        NavigationSplitView {
          SidebarView(selection: $navigation.screen)
        } detail: {
          switch navigation.screen {
          case .today, .none: TodayListView()
          case .backlog: BacklogListView()
          case .rings: RingsView()
          }
        }
        #if os(iOS)
          .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
              Button("Settings", systemImage: "gearshape") { isShowingSettings = true }
            }
          }
          .sheet(isPresented: $isShowingSettings) {
            NavigationStack {
              SettingsView()
              .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                  Button("Done") { isShowingSettings = false }
                }
              }
            }
          }
        #endif
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
