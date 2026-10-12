import SwiftUI
import TodayKit

/// The day rings, one per row, today at the top.
struct RingsView: View {
  @Environment(RemindersStore.self) private var store
  @State private var rings: [DayRing] = []

  var body: some View {
    List(rings, id: \.day) { ring in
      RingRow(ring: ring, relation: relation(of: ring.day))
    }
    .listStyle(.plain)
    .navigationTitle("Rings")
    .toolbarTitleDisplayMode(.inline)
    .task(id: store.reloadCount) {
      let today = store.today
      // Launched with -fakeRings, the screen shows one day per tenth, for looking at the symbols. Nothing is stored.
      if LaunchArguments.fakesRings {
        rings = (0...11).map { offset in
          let day = today.advanced(by: -offset)
          return offset == 11
            ? DayRing(day: day, completed: 0, total: 0) : DayRing(day: day, completed: 10 - offset, total: 10)
        }
        return
      }
      let history = await store.fetchHistory()
      // The last row is the first day anything was ever on the Today list. Before that there is nothing to say.
      let first = history.compactMap { $0.metadata?.days.first }.min() ?? today
      let oldestFirst = DayRing.computeRange(from: first, through: today, items: history, endOfDay: store.settings.endOfDay)
      rings = oldestFirst.reversed()
    }
  }

  private func relation(of day: LogicalDay) -> String? {
    switch day {
    case store.today: "Today"
    case store.today.advanced(by: -1): "Yesterday"
    default: nil
    }
  }
}
