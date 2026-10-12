import SwiftUI
import TodayKit

/// The trinary circle: empty, half, or full, where a tap moves to the next state.
struct CheckCircle: View {
  let state: CheckState
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Image(systemName: symbol)
        .scaledFont(.title3)
        .foregroundStyle(state == .todo ? .secondary : Color.accentColor)
        .contentTransition(.symbolEffect(.replace))
    }
    .buttonStyle(.plain)
    .accessibilityLabel(label)
  }

  private var symbol: String {
    switch state {
    case .todo: "circle"
    case .doing: "circle.lefthalf.filled"
    case .done: "checkmark.circle.fill"
    }
  }

  private var label: String {
    switch state {
    case .todo: "To do"
    case .doing: "In progress"
    case .done: "Done"
    }
  }
}
