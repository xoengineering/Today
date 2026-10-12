import EventKit
import SwiftUI

struct ContentView: View {
  @Environment(RemindersStore.self) private var store

  var body: some View {
    VStack(spacing: 16) {
      switch store.authorization {
      case .fullAccess:
        Text("Reminders access granted.")
      case .notDetermined:
        Button("Allow Reminders Access") {
          Task { await store.requestAccess() }
        }
      default:
        Text("Today needs full access to Reminders. Grant it in System Settings, Privacy & Security, Reminders.")
          .multilineTextAlignment(.center)
      }
    }
    .padding()
    .frame(minWidth: 320, minHeight: 240)
    .task {
      guard store.authorization == .notDetermined else { return }
      await store.requestAccess()
    }
  }
}
