import SwiftUI
import TodayKit

/// What an empty bucket shows, since reaching it is the point.
struct EmptyBucketView: View {
  @Environment(RemindersStore.self) private var store
  @Environment(\.textScale) private var textScale
  let bucket: Bucket

  var body: some View {
    VStack(spacing: 12) {
      Image(systemName: symbol)
        .font(.system(size: 44 * textScale))
        .foregroundStyle(.secondary)
        .symbolEffect(.bounce, value: store.completedTodayCount)
      Text(headline)
        .scaledFont(.title3)
      Text(detail)
        .scaledFont(.body)
        .foregroundStyle(.secondary)
    }
    .multilineTextAlignment(.center)
    .padding()
  }

  private var finishedEverything: Bool {
    bucket == .today && store.completedTodayCount > 0
  }

  private var symbol: String {
    switch bucket {
    case .today: finishedEverything ? "checkmark.circle.fill" : "sun.max.fill"
    case .backlog: "tray.fill"
    }
  }

  private var headline: String {
    switch bucket {
    case .today: finishedEverything ? "All done for today" : "Nothing on the list for today"
    case .backlog: "The backlog is empty"
    }
  }

  private var detail: String {
    switch bucket {
    case .today:
      finishedEverything
        ? "\(store.completedTodayCount) finished, enjoy the rest of it"
        : "Add something new or pull something in from the Backlog"
    case .backlog:
      "Nothing is waiting on you"
    }
  }
}
