import SwiftUI

/// The three screens, with no counts and no badges.
struct SidebarView: View {
  @Binding var selection: Screen?
  @State private var isShowingSettings = false

  var body: some View {
    List(Screen.allCases, selection: $selection) { screen in
      Label {
        Text(screen.title)
      } icon: {
        // Filled when selected, outlined otherwise, always in the text's own color.
        // The macOS sidebar tints label icons with the accent color. A concrete color, not the hierarchical
        // style, is what overrides that.
        Image(systemName: selection == screen ? screen.selectedSymbol : screen.symbol)
          .foregroundStyle(Color.primary)
      }
    }
    .navigationTitle("Today")
    .toolbarTitleDisplayMode(.inline)
    #if os(iOS)
      // macOS has the Settings scene and ⌘, for this.
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
  }
}
