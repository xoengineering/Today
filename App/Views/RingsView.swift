import SwiftUI
import TodayKit

/// The day rings, a week per row, the most recent weeks.
struct RingsView: View {
  @Environment(RemindersStore.self) private var store
  @State private var rings: [DayRing] = []

  private let weeks = 8
  private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 7)

  var body: some View {
    ScrollView {
      LazyVGrid(columns: columns, spacing: 12) {
        ForEach(RingCalendar.weekdaySymbols(), id: \.self) { symbol in
          Text(symbol)
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        ForEach(rings, id: \.day) { ring in
          VStack(spacing: 4) {
            RingView(ring: ring)
              .frame(width: 36, height: 36)
              .opacity(ring.day > store.today ? 0.3 : 1)
            Text("\(ring.day.day)")
              .font(.caption2)
              .foregroundStyle(ring.day == store.today ? .primary : .secondary)
          }
        }
      }
      .padding()
      .frame(maxWidth: 480)
      // The scroll content spans the window, so the title bar does too. Only the grid is capped.
      .frame(maxWidth: .infinity)
    }
    .navigationTitle("Rings")
    .task(id: store.reloadCount) {
      let history = await store.fetchHistory()
      let days = RingCalendar.days(endingOn: store.today, weeks: weeks)
      guard let first = days.first, let last = days.last else { return }
      rings = DayRing.computeRange(from: first, through: last, items: history, endOfDay: store.settings.endOfDay)
    }
  }
}
