import Foundation

/// The launch arguments the screenshot script and hand testing use, none of which do anything in normal use.
///
/// `-demo` fills the app with canned items instead of reading Reminders. `-finished` makes the demo's Today items all
/// done. `-screen <today|backlog|rings>` picks the first screen. `-settings <general|appearance>` opens Settings on a tab.
/// `-fakeRings` shows one synthetic day per tenth on the Rings screen.
enum LaunchArguments {
  static var isDemo: Bool { has("-demo") }
  static var isFinished: Bool { has("-finished") }
  static var fakesRings: Bool { has("-fakeRings") }

  static var screen: Screen? {
    value(after: "-screen").flatMap(Screen.init(rawValue:))
  }

  static var settingsTab: SettingsTab? {
    value(after: "-settings").flatMap(SettingsTab.init(rawValue:))
  }

  private static func has(_ flag: String) -> Bool {
    CommandLine.arguments.contains(flag)
  }

  private static func value(after flag: String) -> String? {
    guard let index = CommandLine.arguments.firstIndex(of: flag), index + 1 < CommandLine.arguments.count else {
      return nil
    }
    return CommandLine.arguments[index + 1]
  }
}

enum SettingsTab: String {
  case general
  case appearance
}
