import EventKit
import SwiftUI

/// Shown until the app has full access to Reminders.
struct AccessView: View {
  @Environment(RemindersStore.self) private var store

  var body: some View {
    VStack(spacing: 16) {
      Image(systemName: "checklist")
        .font(.system(size: 44))
        .foregroundStyle(.tint)
      Text("Today is a view on your Reminders.")
        .font(.title3)
      switch store.authorization {
      case .notDetermined:
        Text("It needs full access to read and edit the reminders in your Today and Backlog lists.")
          .foregroundStyle(.secondary)
        Button("Allow Reminders Access") {
          Task { await store.requestAccess() }
        }
        .buttonStyle(.borderedProminent)
      default:
        Text("Grant it full access to Reminders in System Settings, Privacy & Security, Reminders, then come back.")
          .foregroundStyle(.secondary)
      }
    }
    .multilineTextAlignment(.center)
    .frame(maxWidth: 360)
    .padding()
  }
}
