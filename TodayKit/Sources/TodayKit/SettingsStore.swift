import Foundation

/// Reads and writes `AppSettings` as one JSON value in a `UserDefaults` suite.
///
/// The suite is the app group's, so the widget reads what the app wrote.
public struct SettingsStore {
  public static let key = "settings"

  private let defaults: UserDefaults

  public init(defaults: UserDefaults) {
    self.defaults = defaults
  }

  public func load() -> AppSettings {
    guard let data = defaults.data(forKey: Self.key),
      let settings = try? JSONDecoder().decode(AppSettings.self, from: data)
    else { return AppSettings() }
    return settings
  }

  public func save(_ settings: AppSettings) {
    // AppSettings is strings and integers, so encoding cannot fail.
    guard let data = try? JSONEncoder().encode(settings) else { return }
    defaults.set(data, forKey: Self.key)
  }
}
