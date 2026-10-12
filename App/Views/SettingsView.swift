import SwiftUI

/// The Settings window: General and Appearance tabs.
struct SettingsView: View {
  @State private var selection = LaunchArguments.settingsTab ?? .general

  var body: some View {
    TabView(selection: $selection) {
      Tab("General", systemImage: "gearshape", value: SettingsTab.general) {
        GeneralSettingsView()
      }
      Tab("Appearance", systemImage: "textformat", value: SettingsTab.appearance) {
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
  /// A grouped form, which is what every settings pane is.
  ///
  /// On macOS the window hugs the form, so the form neither scrolls nor stretches. On iOS a form sized that way
  /// comes out empty, and the sheet scrolls like any other.
  func settingsForm() -> some View {
    formStyle(.grouped)
      #if os(macOS)
        .scrollDisabled(true)
        .fixedSize(horizontal: false, vertical: true)
      #endif
  }
}
