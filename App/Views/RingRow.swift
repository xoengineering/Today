import SwiftUI
import TodayKit

/// One day on the Rings screen: the ring, the date, and "Today" or "Yesterday" when it applies.
///
/// The finished count is shown only while everything fits on one line. The date never wraps for its sake.
struct RingRow: View {
  @Environment(RemindersStore.self) private var store
  let ring: DayRing
  let relation: String?

  var body: some View {
    HStack(spacing: 8) {
      RingView(ring: ring)
        .frame(width: 28 * store.settings.textSize.ringScale, height: 28 * store.settings.textSize.ringScale)
      ViewThatFits(in: .horizontal) {
        HStack(spacing: 12) {
          labels.fixedSize()
          Spacer(minLength: 12)
          count
        }
        HStack(spacing: 12) {
          labels.fixedSize()
          Spacer(minLength: 0)
        }
        labels
      }
    }
    .scaledFont(.body)
    .listRowSeparator(.hidden)
  }

  /// One string, so the relation wraps along with the date instead of standing beside it.
  private var labels: Text {
    let date = Text(store.settings.dateFormat.format(ring.day))
    guard let relation else { return date }
    return date + Text(" (\(relation))").foregroundStyle(.secondary)
  }

  @ViewBuilder private var count: some View {
    if ring.total > 0 {
      Text("\(ring.completed) of \(ring.total)")
        .foregroundStyle(.secondary)
        .monospacedDigit()
    }
  }
}
