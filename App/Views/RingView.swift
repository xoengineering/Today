import SwiftUI
import TodayKit

/// One day's ring: gray when nothing was planned, otherwise green for finished and red for not.
struct RingView: View {
  let ring: DayRing
  var lineWidth: CGFloat = 4

  var body: some View {
    ZStack {
      Circle()
        .stroke(.quaternary, lineWidth: lineWidth)
      if ring.total > 0 {
        Circle()
          .trim(from: 0, to: ring.completedFraction)
          .stroke(.green, style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt))
        Circle()
          .trim(from: ring.completedFraction, to: 1)
          .stroke(.red, style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt))
      }
    }
    .rotationEffect(.degrees(-90))
    .accessibilityLabel("\(ring.day.description): \(ring.completed) of \(ring.total) done")
  }
}
