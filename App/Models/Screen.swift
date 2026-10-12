import SwiftUI

/// The sidebar entries: two buckets and the rings.
enum Screen: String, CaseIterable, Identifiable, Hashable {
  case today
  case backlog
  case rings

  var id: Self { self }

  var title: String {
    switch self {
    case .today: "Today"
    case .backlog: "Backlog"
    case .rings: "Rings"
    }
  }

  var symbol: String {
    switch self {
    case .today: "sun.max"
    case .backlog: "tray"
    case .rings: "circle.circle"
    }
  }

  /// The filled variant, for the selected row.
  var selectedSymbol: String {
    symbol + ".fill"
  }

  /// ⌘1, ⌘2, ⌘3, in sidebar order.
  var shortcut: KeyEquivalent {
    switch self {
    case .today: "1"
    case .backlog: "2"
    case .rings: "3"
    }
  }
}
