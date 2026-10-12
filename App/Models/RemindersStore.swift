import EventKit
import Observation

/// The single EventKit adapter.
///
/// Everything the app knows about Reminders goes through here.
@MainActor
@Observable
final class RemindersStore {
  private(set) var authorization: EKAuthorizationStatus

  private let eventStore = EKEventStore()

  init() {
    authorization = EKEventStore.authorizationStatus(for: .reminder)
  }

  func requestAccess() async {
    do {
      _ = try await eventStore.requestFullAccessToReminders()
    } catch {
      // The status below says what the user chose. The error adds nothing.
    }
    authorization = EKEventStore.authorizationStatus(for: .reminder)
  }
}
