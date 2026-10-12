import Testing
import TodayKit

@Suite struct TextSizeTests {
  @Test func stepsUpAndDownAndStopsAtTheEnds() {
    #expect(TextSize.medium.bigger == .large)
    #expect(TextSize.medium.smaller == .small)
    #expect(TextSize.huge.bigger == .huge)
    #expect(TextSize.small.smaller == .small)
  }

  @Test func hasFiveStepsWithMediumSecond() {
    #expect(TextSize.allCases.count == 5)
    #expect(TextSize.allCases[1] == .medium)
  }
}
