# Findings

Platform quirks, SDK gotchas, and tool behaviors met while building Today. Each entry describes the mechanism as it is, so a future reader can act on it without the history.

## EventKit

- There is no public API for Reminders tags, flags, attachments, subtasks, sections, or manual sort order. The full surface is `EKReminder`, `EKCalendarItem`, `EKCalendar`, and `EKEventStore` as listed in [PLAN.md](PLAN.md) §1.
- `saveReminder` and `removeReminder` are prohibited on watchOS. A watch app could only read.
- A `#hashtag` written into a reminder's title through EventKit stays literal text. The Reminders app does not turn it into a tag. Tags are only ever created inside the Reminders app itself.
- The notes footer survives a round trip through the Reminders app: editing the footer line by hand in Reminders changes what Today reads, and the text above it is untouched.

## Simulator

- Xcode 27.0 on this machine has no `Simulator.app` anywhere under `Xcode.app`, so `open -a Simulator` fails. `simctl` still boots devices, installs, launches, grants privacy (`xcrun simctl privacy <udid> grant reminders engineering.xo.Today`), and takes screenshots (`xcrun simctl io <udid> screenshot out.png`) headless. `script/run ios` treats the window as optional.
- The iOS 27.0 runtime ships `iPhone 17`, `iPhone 17e`, `iPhone Air`, and `iPhone 18 Pro` devices. There is no `iPhone 17 Pro` in it.

## App icon

- The app icon is an Icon Composer document, `App/Today.icon`: an `icon.json` plus layer images under `Assets/`, SVG included. `project.yml` adds it as a single resource file and sets `ASSETCATALOG_COMPILER_APPICON_NAME` to its name. actool compiles it into `Assets.car` and sets `CFBundleIconName`.
- A `linear-gradient` fill takes exactly two colors. Three stops fail the build with "Failed to create a catalog from the Icon Studio document" and nothing more specific.

## SF Symbols

- `Image(systemName: "circle", variableValue:)` changes nothing in the default or `.color` variable modes. Only `.symbolVariableValueMode(.draw)` responds, drawing the value's share as an arc from twelve o'clock. The remainder is not removed, it is the same color at low opacity, in monochrome, palette, and hierarchical alike. A palette's second color never reaches the remainder, so a two-color ring (done in green, left in red) cannot come from the symbol. Rendered and compared with `ImageRenderer` on macOS 27.
- Menus and swipe actions apply the `.fill` variant to their symbols on their own, and `.symbolVariant(.none)` does not undo it there. Swipe actions also ignore transforms on the icon view. A symbol with no filled form, such as `circle.dashed`, is the way to keep an outline.

## Swift concurrency

- A closure passed to `EKEventStore.fetchReminders(matching:completion:)` from inside a `@MainActor` method is inferred to be main-actor isolated, and EventKit invokes it on a private dispatch queue. Under Swift 6 the runtime asserts the isolation on entry and the app dies with `EXC_BREAKPOINT` in `_dispatch_assert_queue_fail`. Mark the closure `@Sendable` so it is non-isolated, map the reminders to `Sendable` values inside it, and resume a continuation with those.

## Signing

- The identifier in parentheses in an `Apple Development: Name (XXXXXXXXXX)` certificate is the developer's own ID, not the team. The team is the certificate's OU. `codesign -dv` on the built app reports the real `TeamIdentifier`. Reading the parenthetical as a team ID sends you chasing a second account that does not exist.
- Automatic signing with `-allowProvisioningUpdates` needs a live Xcode account session for the team. When the session is rejected ("The login details for account ... were rejected"), no profile can be fetched and the build fails before compiling. Manual signing with `CODE_SIGN_IDENTITY = Developer ID Application` builds a sandboxed Debug app with no profile, including the `get-task-allow` entitlement Xcode injects for Debug.
- On macOS, an app group spelled `$(TeamIdentifierPrefix)engineering.xo.Today` resolves to `<team ID>.engineering.xo.Today` under either Developer ID or Apple Development signing, with no profile. `TeamIdentifierPrefix` is set by Xcode from `DEVELOPMENT_TEAM`. A `group.`-prefixed macOS group needs a profile that carries it. Without one the container directory is created but every preferences write into it is dropped, with nothing in the unified log. The tell is an empty `~/Library/Group Containers/group.<...>/Library/Preferences/`.
- Adding App Groups in Xcode's Signing & Capabilities tab, with the entitlement already present, still produced the `Mac Team Provisioning Profile: *` wildcard on every build, with or without `SystemCapabilities` attributes in the project. Xcode decides a Mac Debug build needs no app-specific profile for app groups, and it creates no App ID for it either. The team-prefixed form sidesteps the whole question on macOS.
- What does create the App IDs and register the App Group on them is a device build: `xcodebuild -destination "generic/platform=iOS" -allowProvisioningUpdates -allowProvisioningDeviceRegistration build`. One run produced `iOS Team Provisioning Profile: engineering.xo.Today` and `...Widgets`, each carrying `group.engineering.xo.Today`, and both App IDs appeared on the developer portal. No Signing & Capabilities visit needed, with the `SystemCapabilities` attributes in `project.yml`.
- Right after `-allowProvisioningUpdates` creates a profile, the first build can fail with "Build input file cannot be found: `.../Provisioning Profiles/<uuid>.provisionprofile"`. The file arrives a moment later. Running the build again succeeds.
- Build setting conditionals work in `project.yml` settings keys, for example `APP_GROUP_IDENTIFIER[sdk=macosx*]`. XcodeGen passes them through verbatim.
