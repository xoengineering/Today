import SwiftUI
import TodayKit

/// The trinary circle, where a click moves forward and an option-click or command-click moves back.
struct CheckCircle: View {
  let state: CheckState
  let advance: () -> Void
  let retreat: () -> Void

  var body: some View {
    // Three symbols stacked, one visible per state, so each change is a crossfade the animation controls.
    ZStack {
      Image(systemName: CheckState.todo.symbol)
        .opacity(state == .todo ? 1 : 0)
      Image(systemName: CheckState.doing.symbol)
        // The half-filled symbol splits vertically. Turned, the split runs from bottom left to top right.
        .rotationEffect(.degrees(state == .doing ? 45 : 0))
        .opacity(state == .doing ? 1 : 0)
      Image(systemName: CheckState.done.symbol)
        .opacity(state == .done ? 1 : 0)
    }
    .scaledFont(.title3)
    .foregroundStyle(state == .todo ? .secondary : Color.accentColor)
    // Animates the fades, the color, and the turn whenever the state changes.
    .animation(.bouncy(duration: 0.4, extraBounce: 0.2), value: state)
    .contentShape(Circle())
    #if os(macOS)
      // The modified clicks take priority, so a plain click is the only thing left for the tap below.
      // iOS has no modifier keys. There, the swipe and the context menu step back.
      .highPriorityGesture(TapGesture().modifiers(.option).onEnded(retreat))
      .highPriorityGesture(TapGesture().modifiers(.command).onEnded(retreat))
    #endif
    .onTapGesture(perform: advance)
    .accessibilityAddTraits(.isButton)
    .accessibilityLabel(state.label)
    .accessibilityAction(named: "Back") { retreat() }
  }
}
