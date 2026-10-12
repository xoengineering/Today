import Foundation
import Testing
import TodayKit

@Suite struct DateFormatChoiceTests {
  let day = LogicalDay(year: 2026, month: 10, day: 11)
  let calendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "America/Los_Angeles")!
    return calendar
  }()
  let unitedStates = Locale(identifier: "en_US")

  func format(_ choice: DateFormatChoice, locale: Locale? = nil) -> String {
    choice.format(day, calendar: calendar, locale: locale ?? unitedStates)
  }

  @Test func iso8601IgnoresTheLocale() {
    #expect(format(.iso8601) == "2026-10-11")
    #expect(format(.iso8601, locale: Locale(identifier: "de_DE")) == "2026-10-11")
  }

  @Test func localizedStylesFollowTheLocale() {
    #expect(format(.system) == "Oct 11, 2026")
    #expect(format(.long) == "October 11, 2026")
    #expect(format(.complete) == "Sunday, October 11, 2026")
    #expect(format(.numeric) == "10/11/2026")
    #expect(format(.numeric, locale: Locale(identifier: "en_GB")) == "11/10/2026")
  }

  @Test func everyChoiceHasALabel() {
    for choice in DateFormatChoice.allCases {
      #expect(!choice.label.isEmpty)
    }
  }
}
