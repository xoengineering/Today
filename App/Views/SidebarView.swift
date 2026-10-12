import SwiftUI

/// The three screens, with no counts and no badges.
struct SidebarView: View {
  @Binding var selection: Screen?

  var body: some View {
    List(Screen.allCases, selection: $selection) { screen in
      Label(screen.title, systemImage: screen.symbol)
    }
    .navigationTitle("Today")
  }
}
