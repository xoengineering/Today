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
}
