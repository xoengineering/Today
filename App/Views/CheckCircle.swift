import SwiftUI
import TodayKit

/// The trinary circle: empty, half, or full, where a click moves to the next state.
struct CheckCircle: View {
  let state: CheckState
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      // Three symbols stacked, one visible per state, so each change is a crossfade the animation controls.
      ZStack {
        Image(systemName: "circle")
          .opacity(state == .todo ? 1 : 0)
        Image(systemName: "circle.lefthalf.filled")
          // The half-filled symbol splits vertically. Turned, the split runs from bottom left to top right.
          .rotationEffect(.degrees(state == .doing ? 45 : 0))
          .opacity(state == .doing ? 1 : 0)
        Image(systemName: "checkmark.circle.fill")
          .opacity(state == .done ? 1 : 0)
      }
      .scaledFont(.title3)
      .foregroundStyle(state == .todo ? .secondary : Color.accentColor)
      // Animates the fades, the color, and the turn whenever the state changes.
      .animation(.bouncy(duration: 0.4, extraBounce: 0.2), value: state)
    }
    .buttonStyle(.plain)
    .accessibilityLabel(label)
  }

  private var label: String {
    switch state {
    case .todo: "To do"
    case .doing: "In progress"
    case .done: "Done"
    }
  }
}
