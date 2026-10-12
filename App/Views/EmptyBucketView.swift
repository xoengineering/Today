import SwiftUI
import TodayKit

/// What an empty bucket shows, since reaching it is the point.
struct EmptyBucketView: View {
  let bucket: Bucket

  var body: some View {
    VStack(spacing: 12) {
      Image(systemName: bucket == .today ? "sun.max.fill" : "tray.fill")
        .font(.system(size: 44))
        .foregroundStyle(.tint)
      Text(bucket == .today ? "Nothing left for today." : "The backlog is empty.")
        .font(.title3)
      Text(bucket == .today ? "Enjoy the rest of it." : "Nothing is waiting on you.")
        .foregroundStyle(.secondary)
    }
    .multilineTextAlignment(.center)
    .padding()
  }
}
