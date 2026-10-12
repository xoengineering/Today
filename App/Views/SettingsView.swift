import EventKit
import SwiftUI
import TodayKit

/// End of day and the two lists, which is all there is to configure.
struct SettingsView: View {
  @Environment(RemindersStore.self) private var store

  var body: some View {
    Form {
      Section {
        DatePicker("End of day", selection: endOfDayBinding, displayedComponents: .hourAndMinute)
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
      Section {
        Slider(value: textSizeSlider, in: 0...Double(TextSize.allCases.count - 1), step: 1) {
          Text("Text size")
        } minimumValueLabel: {
          Text("A").font(.caption2)
        } maximumValueLabel: {
          Text("A").font(.title2)
        }
        .labelsHidden()
      } header: {
        Text("Text size")
      } footer: {
        Text(store.settings.textSize.label)
      }
      Section {
        Picker("Date format", selection: dateFormatBinding) {
          ForEach(DateFormatChoice.allCases, id: \.self) { choice in
            Text(choice.label).tag(choice)
          }
        }
      } header: {
        Text("Rings")
      } footer: {
        Text("Today is \(store.settings.dateFormat.format(store.today))")
      }
    }
    .formStyle(.grouped)
    // The window fits the form. Nothing here is long enough to scroll.
    .scrollDisabled(true)
    .fixedSize(horizontal: false, vertical: true)
    // The window would otherwise hand focus to the stepper. Tab still reaches it.
    .resignInitialFocus()
    .navigationTitle("Settings")
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

  /// The slider's floating-point value, mapped onto the five text size steps.
  private var textSizeSlider: Binding<Double> {
    Binding(
      get: { Double(TextSize.allCases.firstIndex(of: store.settings.textSize) ?? 1) },
      set: { value in
        let index = Int(value.rounded())
        store.settings.textSize = TextSize.allCases[max(0, min(index, TextSize.allCases.count - 1))]
      })
  }

  private var dateFormatBinding: Binding<DateFormatChoice> {
    @Bindable var store = store
    return $store.settings.dateFormat
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
