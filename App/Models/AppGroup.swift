import Foundation
import TodayKit

/// The container the app and the widget share, whose identifier is a build setting read from Info.plist.
enum AppGroup {
  static var identifier: String? {
    Bundle.main.object(forInfoDictionaryKey: "TodayAppGroupIdentifier") as? String
  }

  /// The shared defaults, or the app's own when the group is not provisioned on this build.
  static var defaults: UserDefaults {
    guard let identifier, let shared = UserDefaults(suiteName: identifier) else { return .standard }
    return shared
  }

  static var settingsStore: SettingsStore {
    SettingsStore(defaults: defaults)
  }
}
