import SwiftUI

/// The Settings window: General and Appearance tabs.
struct SettingsView: View {
  var body: some View {
    TabView {
      Tab("General", systemImage: "gearshape") {
        GeneralSettingsView()
      }
      Tab("Appearance", systemImage: "textformat") {
        AppearanceSettingsView()
      }
    }
    #if os(macOS)
      // The tab strip's material lights up under the pointer when a pane holds a scroll view. A form is one.
      .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
    #endif
  }
}

extension View {
  /// A grouped form that fits its content with no scrolling, which is what every settings pane is.
  func settingsForm() -> some View {
    formStyle(.grouped)
      .scrollDisabled(true)
      .fixedSize(horizontal: false, vertical: true)
  }
}
