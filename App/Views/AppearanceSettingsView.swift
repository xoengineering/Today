import SwiftUI
import TodayKit

/// Text size, typeface, and how the Rings screen writes its dates.
struct AppearanceSettingsView: View {
  @Environment(RemindersStore.self) private var store

  var body: some View {
    @Bindable var store = store
    Form {
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
        FontThemePicker(selection: $store.settings.fontTheme)
      } header: {
        Text("Typeface")
      }
      Section {
        Picker("Date format", selection: $store.settings.dateFormat) {
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
    .settingsForm()
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
}
