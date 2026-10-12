import EventKit
import SwiftUI
import TodayKit

/// End of day and the two Reminders lists.
struct GeneralSettingsView: View {
  @Environment(RemindersStore.self) private var store

  var body: some View {
    Form {
      Section {
        DatePicker("Reset time", selection: endOfDayBinding, displayedComponents: .hourAndMinute)
      } header: {
        Text("End of day")
      } footer: {
        Text("Items in the Today list move to Backlog at this time")
      }
      Section {
        Picker("Today list", selection: todayListBinding) {
          ForEach(store.lists, id: \.calendarIdentifier) { list in
            Text(list.title).tag(list.calendarIdentifier)
          }
        }
        Picker("Backlog list", selection: backlogListBinding) {
          ForEach(store.lists, id: \.calendarIdentifier) { list in
            Text(list.title).tag(list.calendarIdentifier)
          }
        }
      } header: {
        Text("Reminders integration")
      } footer: {
        Text("This app only uses these two Reminders lists")
      }
    }
    .settingsForm()
    // The window would otherwise hand focus to the stepper. Tab still reaches it.
    .resignInitialFocus()
  }

  private var endOfDayBinding: Binding<Date> {
    Binding(
      get: {
        let components = DateComponents(hour: store.settings.endOfDay.hour, minute: store.settings.endOfDay.minute)
        return Calendar.current.date(from: components) ?? .now
      },
      set: { date in
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let endOfDay = EndOfDay(hour: components.hour ?? 4, minute: components.minute ?? 0)
        Task { await store.setEndOfDay(endOfDay) }
      })
  }

  private var todayListBinding: Binding<String> {
    Binding(
      get: { store.todayList?.calendarIdentifier ?? "" },
      set: { identifier in
        guard let list = store.lists.first(where: { $0.calendarIdentifier == identifier }) else { return }
        Task { await store.useTodayList(list) }
      })
  }

  private var backlogListBinding: Binding<String> {
    Binding(
      get: { store.backlogList?.calendarIdentifier ?? "" },
      set: { identifier in
        guard let list = store.lists.first(where: { $0.calendarIdentifier == identifier }) else { return }
        Task { await store.useBacklogList(list) }
      })
  }
}
