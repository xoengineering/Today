import Testing
import TodayKit

@Suite struct TextSizeTests {
  @Test func stepsUpAndDownAndStopsAtTheEnds() {
    #expect(TextSize.medium.bigger == .large)
    #expect(TextSize.medium.smaller == .small)
    #expect(TextSize.giant.bigger == .giant)
    #expect(TextSize.small.smaller == .small)
  }

  @Test func hasSixStepsWithMediumSecond() {
    #expect(TextSize.allCases.count == 6)
    #expect(TextSize.allCases[1] == .medium)
  }
}
