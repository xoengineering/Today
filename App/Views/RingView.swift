import SwiftUI
import TodayKit

/// One day's ring: gray when nothing was planned, otherwise green for finished and red for not.
struct RingView: View {
  let ring: DayRing
  var lineWidth: CGFloat = 4

  var body: some View {
    // The stroke is drawn inside the frame, so the ring's outer edge is the frame's edge and lines up with text.
    let path = Circle().inset(by: lineWidth / 2)
    ZStack {
      path
        .stroke(.quaternary, lineWidth: lineWidth)
      if ring.total > 0 {
        path
          .trim(from: 0, to: ring.completedFraction)
          .stroke(.green, style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt))
        path
          .trim(from: ring.completedFraction, to: 1)
          .stroke(.red, style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt))
      }
    }
    .rotationEffect(.degrees(-90))
    .accessibilityLabel("\(ring.day.description): \(ring.completed) of \(ring.total) done")
  }
}
