import SwiftUI
import TodayKit

/// One day on the Rings screen: the ring, the date, and "Today" or "Yesterday" when it applies.
struct RingRow: View {
  @Environment(RemindersStore.self) private var store
  let ring: DayRing
  let relation: String?

  var body: some View {
    HStack(spacing: 12) {
      RingView(ring: ring)
        .frame(width: 28, height: 28)
      Text(store.settings.dateFormat.format(ring.day))
      if let relation {
        Text("(\(relation))")
          .foregroundStyle(.secondary)
      }
      Spacer()
      if ring.total > 0 {
        Text("\(ring.completed) of \(ring.total)")
          .foregroundStyle(.secondary)
          .monospacedDigit()
      }
    }
    .padding(.vertical, 4)
  }
}
