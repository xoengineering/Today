# Development

macOS, iOS, and iPadOS 27 or later. Swift 6.4 or later. SwiftUI. Swift Testing.

## Scripts

- `script/setup` installs tools, generates `Today.xcodeproj` (XcodeGen), and creates `Local.xcconfig` from the example. Set `DEVELOPMENT_TEAM` in it to your Apple Developer Team ID. It is gitignored, so no one's team ID is in the repo.
- `script/test` runs the TodayKit test suite.
- `script/build [macos|ios]` builds the app.
- `script/lint` and `script/format` run swift format and SwiftLint.
- `script/run` builds and launches the macOS app.
- `script/run ios` builds, installs, and launches in the iOS Simulator. Takes an optional simulator name: `script/run ios "iPad Pro 11-inch (M5)"`. Only iOS 27 simulators are eligible. Grant the simulator app Reminders access without the prompt with `xcrun simctl privacy booted grant reminders engineering.xo.Today`.
- `script/run device` builds, installs, and launches on the first paired iPhone or iPad, or a named one: `script/run device <udid>` with an identifier from `xcrun devicectl list devices`. The device needs Developer Mode enabled and `DEVELOPMENT_TEAM` set in `Local.xcconfig`. The first run registers the device with your team.
- `script/icon-sky` redraws the app icon's sky layer after a change to its patches.
- `script/index` teaches sourcekit-lsp the Xcode build settings, so editors other than Xcode resolve `TodayKit` and `Testing` in app and test files. Restart the editor's language server after it runs.
- `script/cibuild` is what CI runs: lint, tests, and both platform builds.

## Documents

- [PLAN.md](PLAN.md) is the design: what the Reminders API offers, how the app maps onto it, and what is still open.
- [findings.md](findings.md) records platform quirks and tool behaviors met along the way, so nobody meets them twice.
