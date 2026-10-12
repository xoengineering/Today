import SwiftUI
import TodayKit

/// One day on the Rings screen, laid out like an item row: the day's symbol, then the date.
///
/// "(Today)" and "(Yesterday)" are part of the date string, so they wrap with it.
struct RingRow: View {
  @Environment(RemindersStore.self) private var store
  let ring: DayRing
  let relation: String?

  var body: some View {
    HStack(alignment: .top, spacing: 8) {
      // A part-done day is the plain circle in draw mode: the finished share as a bright arc, the rest dimmed.
      // The circle only honors its variable value in draw mode, and no mode gives the rest a second color.
      Image(systemName: ring.symbol, variableValue: ring.completedFraction)
        .symbolVariableValueMode(.draw)
        .scaledFont(.title3)
        .foregroundStyle(color)
        .accessibilityLabel("\(ring.completed) of \(ring.total) done")
      // The finished count is shown only while everything fits on one line. The date never wraps for its sake.
      ViewThatFits(in: .horizontal) {
        HStack(spacing: 8) {
          label.fixedSize()
          Spacer(minLength: 8)
          count
        }
        HStack(spacing: 8) {
          label.fixedSize()
          Spacer(minLength: 0)
        }
        label
          .fixedSize(horizontal: false, vertical: true)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      .scaledFont(.body)
    }
    .listRowSeparator(.hidden)
  }

  private var color: Color {
    switch ring.outcome {
    case .empty: .secondary
    case .noneDone: .red
    case .someDone, .allDone: .green
    }
  }

  @ViewBuilder private var count: some View {
    if ring.total > 0 {
      Text("\(ring.completed) of \(ring.total)")
        .foregroundStyle(.secondary)
        .monospacedDigit()
    }
  }

  private var label: Text {
    let date = store.settings.dateFormat.format(ring.day)
    guard let relation else { return Text(date) }
    return Text("\(date) \(Text("(\(relation))").foregroundStyle(.secondary))")
  }
}
