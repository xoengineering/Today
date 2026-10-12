import Observation

/// Which screen is showing, and the one request a menu can make of a list: focus the add row.
@MainActor
@Observable
final class NavigationState {
  var screen: Screen? = .today
  /// Bumped by the New Item command, so the visible add row focuses itself.
  var addItemRequest = 0

  /// Goes to Today and asks its add field for focus, whether the field is on screen already or about to appear.
  func requestAddItem() {
    screen = .today
    addFieldHoldsFocus = true
    addItemRequest += 1
  }

  /// Bumped by a tap on a list's empty area, so any focused field lets go and the keyboard goes with it.
  var dismissFocusRequest = 0

  func requestDismissFocus() {
    dismissFocusRequest += 1
    addFieldHoldsFocus = false
  }

  /// Whether the add field had focus when its list was last rebuilt, so the rebuilt field takes it back.
  var addFieldHoldsFocus = false
}
