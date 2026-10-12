# Findings

Platform quirks, SDK gotchas, and tool behaviors met while building Today. Each entry describes the mechanism as it is, so a future reader can act on it without the history.

## EventKit

- There is no public API for Reminders tags, flags, attachments, subtasks, sections, or manual sort order. The full surface is `EKReminder`, `EKCalendarItem`, `EKCalendar`, and `EKEventStore` as listed in `PLAN.md` §1.
- `saveReminder` and `removeReminder` are prohibited on watchOS. A watch app could only read.
- A `#hashtag` written into a reminder's title through EventKit stays literal text. The Reminders app does not turn it into a tag. Tags are only ever created inside the Reminders app itself.
- The notes footer survives a round trip through the Reminders app: editing the footer line by hand in Reminders changes what Today reads, and the text above it is untouched.

## Simulator

- Xcode 27.0 on this machine has no `Simulator.app` anywhere under `Xcode.app`, so `open -a Simulator` fails. `simctl` still boots devices, installs, launches, grants privacy (`xcrun simctl privacy <udid> grant reminders engineering.xo.Today`), and takes screenshots (`xcrun simctl io <udid> screenshot out.png`) headless. `script/run ios` treats the window as optional.
- The iOS 27.0 runtime ships `iPhone 17`, `iPhone 17e`, `iPhone Air`, and `iPhone 18 Pro` devices. There is no `iPhone 17 Pro` in it.

## Swift concurrency

- A closure passed to `EKEventStore.fetchReminders(matching:completion:)` from inside a `@MainActor` method is inferred to be main-actor isolated, and EventKit invokes it on a private dispatch queue. Under Swift 6 the runtime asserts the isolation on entry and the app dies with `EXC_BREAKPOINT` in `_dispatch_assert_queue_fail`. Mark the closure `@Sendable` so it is non-isolated, map the reminders to `Sendable` values inside it, and resume a continuation with those.

## Signing

- The identifier in parentheses in an `Apple Development: Name (XXXXXXXXXX)` certificate is the developer's own ID, not the team. The team is the certificate's OU. `codesign -dv` on the built app reports the real `TeamIdentifier`. Reading the parenthetical as a team ID sends you chasing a second account that does not exist.
- Automatic signing with `-allowProvisioningUpdates` needs a live Xcode account session for the team. When the session is rejected ("The login details for account ... were rejected"), no profile can be fetched and the build fails before compiling. Manual signing with `CODE_SIGN_IDENTITY = Developer ID Application` builds a sandboxed Debug app with no profile, including the `get-task-allow` entitlement Xcode injects for Debug.
- On macOS, an app group spelled `$(TeamIdentifierPrefix)engineering.xo.Today` resolves to `<team ID>.engineering.xo.Today` under Developer ID signing with no profile. `TeamIdentifierPrefix` is set by Xcode from `DEVELOPMENT_TEAM`. A `group.`-prefixed macOS group needs a profile that backs it, or every write into the container fails with `EPERM`.
- Build setting conditionals work in `project.yml` settings keys, for example `APP_GROUP_IDENTIFIER[sdk=macosx*]`. XcodeGen passes them through verbatim.
