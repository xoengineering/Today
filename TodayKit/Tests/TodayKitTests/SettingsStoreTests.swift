import Foundation
import Testing
import TodayKit

@Suite struct SettingsStoreTests {
  let suiteName = "TodayKitTests-\(UUID().uuidString)"

  func withDefaults(_ body: (UserDefaults) throws -> Void) throws {
    let defaults = try #require(UserDefaults(suiteName: suiteName))
    defer { defaults.removePersistentDomain(forName: suiteName) }
    try body(defaults)
  }

  @Test func missingSettingsAreTheDefaults() throws {
    try withDefaults { defaults in
      #expect(SettingsStore(defaults: defaults).load() == AppSettings())
      #expect(AppSettings().endOfDay == EndOfDay(hour: 4))
    }
  }

  @Test func roundTrips() throws {
    try withDefaults { defaults in
      let store = SettingsStore(defaults: defaults)
      let settings = AppSettings(
        endOfDay: EndOfDay(hour: 2, minute: 30), todayListIdentifier: "t", backlogListIdentifier: "b")
      store.save(settings)
      #expect(store.load() == settings)
    }
  }

  @Test func unreadableDataFallsBackToDefaults() throws {
    try withDefaults { defaults in
      defaults.set(Data("nope".utf8), forKey: SettingsStore.key)
      #expect(SettingsStore(defaults: defaults).load() == AppSettings())
    }
  }
}
