import SwiftUI

@main
struct TodayApp: App {
  @State private var store = RemindersStore()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(store)
    }
  }
}
