# Today: Plan

A calm, two-bucket TODO app that is purely a view on top of Apple Reminders. macOS (native, not Catalyst) plus iOS and iPadOS. OS 27 or later, Swift 6.4 or later, SwiftUI only.

## 1. What the public Reminders API (EventKit) gives us

Verified against the Xcode 27.0 and iOS 27.0 SDK headers. There is no other public Reminders framework. EventKitUI only has event editors and `EKCalendarChooser`.

### Available per reminder (`EKReminder` and `EKCalendarItem`)

| Field                              | Type               | Notes                                                                        |
| ---------------------------------- | ------------------ | ---------------------------------------------------------------------------- |
| `title`                            | String             | Plain text                                                                   |
| `notes`                            | String?            | Plain text, user-visible in Reminders                                        |
| `url`                              | URL?               | Shown as a link chip in Reminders                                            |
| `location`                         | String?            | Free-text location                                                           |
| `priority`                         | 0, 1–9             | 0 is none. 1–4 high, 5 medium, 6–9 low (Reminders shows `!`, `!!`, `!!!`)    |
| `startDateComponents`              | DateComponents?    | "Start date". On iOS, a due date requires a start date                       |
| `dueDateComponents`                | DateComponents?    | Date-only components mean all-day                                            |
| `isCompleted` / `completionDate`   | Bool / Date?       | Linked. `completionDate` may be nil if completed by another client           |
| `alarms`                           | [EKAlarm]          | Time-based or location-based (`EKStructuredLocation`, proximity enter/leave) |
| `recurrenceRules`                  | [EKRecurrenceRule] | Full RFC 5545 rules                                                          |
| `timeZone`                         | TimeZone?          |                                                                              |
| `calendar`                         | EKCalendar         | The list. Reassigning moves the reminder between lists                       |
| `creationDate`, `lastModifiedDate` | Date?              | Read-only                                                                    |
| `calendarItemIdentifier`           | String             | Per-device, not stable across devices                                        |
| `calendarItemExternalIdentifier`   | String             | Sync identifier, stable across devices for iCloud lists                      |

### Available per list (`EKCalendar`)

| Field                                                       | Notes                             |
| ----------------------------------------------------------- | --------------------------------- |
| `title`                                                     | Editable                          |
| `cgColor` / `color` (macOS `NSColor`)                       | Editable list color               |
| `source`                                                    | iCloud, local, Exchange, etc.     |
| `allowsContentModifications`, `isImmutable`, `isSubscribed` | Read-only capability flags        |
| Create and delete lists                                     | `saveCalendar` / `removeCalendar` |
| `defaultCalendarForNewReminders`                            | User's default list               |

### Store-level

- Authorization: `requestFullAccessToReminders()`. Statuses are `.fullAccess`, `.writeOnly`, `.denied`, `.restricted`, `.notDetermined`.
- Fetch predicates: all reminders in lists, incomplete by due-date range, completed by completion-date range.
- `EKEventStoreChanged` notification fires for any external change (another device via iCloud, the Reminders app, Siri). The app re-fetches on it.
- `save(_:commit:)` and `remove(_:commit:)` with batch `commit()`.
- watchOS is read-only (save and remove are prohibited). Not a target for now.

### Not available via any public API

| Reminders feature                                                            | Consequence                                                                |
| ---------------------------------------------------------------------------- | -------------------------------------------------------------------------- |
| Tags                                                                         | Can't read or write tags. "In progress" must be encoded elsewhere (see §2) |
| Flag                                                                         | No                                                                         |
| Images and attachments                                                       | No                                                                         |
| Subtasks (parent/child)                                                      | No. Subtasks appear as separate flat reminders                             |
| Sections inside a list                                                       | No                                                                         |
| Smart lists, list icon/emoji, "assigned to", sharing details, early reminder | No                                                                         |
| Manual sort order                                                            | No. Encoded in `notes` (see §2)                                            |

Spike to run (cheap, early): set a title to `Buy milk #inprogress` via EventKit and see whether the Reminders app converts the hashtag into a real tag. If it does, that is a usable (if cosmetic) tag channel. If not, tags are fully off the table.

## 2. Data mapping

### Buckets are two Reminders lists

- **Today** list and **Backlog** list, resolved by title (`Today`, `Backlog`), created by the app on first run if missing. The user can re-point either in Settings.
- Why lists and not due dates: due dates make items turn red and overdue in Reminders after midnight (not calm), and "today" for a nightowl is not a calendar date anyway.
- Moving an item between buckets reassigns `calendar`.
- `calendarIdentifier` is per-device, so list resolution happens on every device. The app stores the chosen identifiers per device in `UserDefaults` (App Group).
- Later option: Backlog is "every other incomplete reminder in every writable list". Not version 1.

### Per-item metadata is a footer line in `notes`

Reminders has no custom fields. `notes` is the only free-form writable text that syncs. The app owns the **last line** of `notes` when it matches the sentinel. Everything above it is the user's own note and is never touched.

```txt
Call the dentist about the thing.
today:{"v":1,"order":3,"state":"doing","days":["2026-10-11"]}
```

- Parsed with `JSONDecoder` into a `Codable` struct, never regex.
- `order` is an Int, the position in the Today list. Only meaningful while in the Today list.
- `state` is `"todo"` or `"doing"`. Done is not stored here, it is `isCompleted`. The trinary circle is derived: completed means `[x]`, otherwise the metadata state.
- `days` is the list of logical days this item was on the Today list. This is the ring history (§4). Appended at most once per day.
- Alternative considered: the `url` field as `today://v1?order=3&state=doing` (parsed by `URLComponents`, less visible). Rejected because `url` is a feature the user will likely want for real links.
- Items with no footer are plain backlog items with default state `todo`.

### Trinary state in the Reminders app

`[ ]` and `[/]` both look like an unchecked reminder in Reminders. `[x]` is a real completion, so Siri, Reminders, and the watch all agree on "done".

## 3. Logical day and end-of-day reset

- Settings: **end of day** hour (default 04:00). Logical day `D` is the interval `[D 04:00, D+1 04:00)` local time. Everything that says "today" means logical day.
- Reset is **lazy**. Whenever the app (or a widget timeline refresh) notices the logical day has advanced past the last-seen day, incomplete Today items move back to Backlog (state reset to `todo`, `order` dropped). Completed ones stay completed in the Today list. Widgets only compute the reset view. Writes happen in the app process.
- Last-seen logical day is stored in App Group `UserDefaults`.
- No background tasks, no notifications. Ever.

## 4. Rings (the only "analytics")

For a logical day `D`:

- Universe: reminders whose `days` includes `D`.
- Green share: those with `completionDate` inside `D`'s interval.
- Red share: the rest.
- Gray: empty universe.

Everything derives from Reminders data, so rings sync across devices for free. Known limits, accepted: deleting a reminder removes it from history. If the user clears completed reminders in the Reminders app, those days turn grayer.

## 5. Architecture

Same shape as Outbox: XcodeGen project, thin app target, logic in a Swift package.

```txt
Today/
  project.yml                 # XcodeGen source of truth. The .xcodeproj is generated and gitignored
  Local.xcconfig              # gitignored: DEVELOPMENT_TEAM (see §6)
  Local.xcconfig.example
  TodayKit/                   # SwiftPM, platform-agnostic, no EventKit import
    Sources/TodayKit/         # ItemMetadata (Codable), LogicalDay, RingSummary, ordering
    Tests/TodayKitTests/      # Swift Testing. Fixtures in Tests/Fixtures/
  App/
    TodayApp.swift
    Info.plist
    Today.entitlements
    Models/                   # RemindersStore (EventKit adapter), TodayItem, settings
    Views/                    # one view per file
  Widgets/                    # WidgetKit extension, one target for macOS and iOS
  script/                     # bootstrap, setup, generate, build, test, lint, format, run, cibuild
```

- `TodayKit` holds all logic that does not need EventKit, so it is fully unit-testable and fast: metadata parse and serialize, logical-day math, reset rules, ring math, reorder operations.
- `RemindersStore` is the single EventKit adapter (`@Observable`, `@MainActor`), translating `EKReminder` to and from `TodayItem`. Listens for `EKEventStoreChanged`.
- One multiplatform app target (`supportedDestinations: [iOS, macOS]`). `#if os(macOS)` only where unavoidable. The Mac gets a real menu bar, `Settings` scene, and keyboard commands.
- One view per file, one model per file.
- Settings shared with the widget via an App Group.
- `swift format` for structure, SwiftLint for style, both `--strict` in `script/lint`. Both tools are installed (XcodeGen 2.46.0, SwiftLint 0.65.1).

## 6. Open source: what lives outside the repo

Nothing in this app needs an API key. There is no backend, no analytics, no iCloud container. The only org-specific values are the signing team and style, kept in `Local.xcconfig` (gitignored). Bundle identifiers and the app group are public strings and live in `project.yml`.

| Key                  | Value                                    | Where it's used                                               |
| -------------------- | ---------------------------------------- | ------------------------------------------------------------- |
| `DEVELOPMENT_TEAM`   | the xo.engineering team ID               | Code signing for the app and widget targets, app group prefix |
| `CODE_SIGN_STYLE`    | `Automatic` or `Manual`                  | Manual when only a Developer ID certificate is on the machine |
| `CODE_SIGN_IDENTITY` | `Developer ID Application` (manual only) | The certificate used for local builds                         |

**Back this up:** `Local.xcconfig`. That is the whole list for now. If a release pipeline is added later (App Store Connect API key for `xcrun altool` or fastlane), its `.p8` key, key ID, and issuer ID join this list. They would live in `~/.appstoreconnect/` or a gitignored file, never in the repo.

`Local.xcconfig.example` is committed with a blank value so contributors can build with their own team. `script/generate` copies it into place when the real one is missing.

Why this is safe: XcodeGen bakes `DEVELOPMENT_TEAM` into `project.pbxproj` at generate time. The project is gitignored, so the baked value never reaches a commit.

The app group identifier differs per platform, through the `APP_GROUP_IDENTIFIER` build setting in `project.yml`. iOS uses `group.engineering.xo.Today`, which the App Groups capability on the App ID backs. macOS uses `$(TeamIdentifierPrefix)engineering.xo.Today`, the form macOS app groups have always taken, which the sandbox honors with no profile at all. Both entitlements files and both Info.plists read the setting, and the app reads the resolved value from its Info.plist at runtime, so the string is never hardcoded in Swift.

The App Groups capability is registered on both App IDs. `project.yml` carries the `SystemCapabilities` target attributes so a regenerated project keeps asking Xcode for profiles with it. Picking a team in Xcode writes it into the pbxproj, so run `script/generate` again after any Signing & Capabilities visit.

## 7. Spikes before committing to the design

1. Hashtag in title: does the Reminders app turn it into a real tag? (§1)
2. A WidgetKit extension can read EventKit using the containing app's authorization on both macOS and iOS (expected yes, confirm).
3. `completionDate` survives iCloud round-trips from other devices (needed for rings). The header warns it can be nil.
4. Notes footer round-trip: write via EventKit, edit the note above it in Reminders on another device, confirm the footer survives untouched.

Spikes are throwaway branches. Anything worth keeping is pasted into `doc/findings.md`, then the branch is deleted.

## 8. Milestones (each a stack of small commits)

1. **App Store**: privacy manifest, usage-description strings, screenshots.

## Open

- The reset time is a per-device setting, and every device applies the rollover. Two devices with different reset times disagree about the date for part of each night, and the one that is "ahead" returns the other's fresh Today items to the Backlog. The rollover now runs once per logical day per device, which stops the back-and-forth, but the setting itself still has to match by hand. Syncing it means storing it in Reminders somewhere, and nothing there is a natural home for an app setting.
- Version 1.1, after 1.0 is through review: a "Show in Reminders" context menu item opening `x-apple-reminderkit://REMCDReminder/<calendarItemIdentifier>`. The scheme is what Notes and Shortcuts use but is undocumented, so nothing else may depend on it.
- A custom SF Symbol for the in-progress circle, split from bottom left to top right, drawn like the app icon's mark. SF Symbols has no diagonal split, the row uses `circle.lefthalf.filled` turned 45°, and swipe actions ignore the turn.
- The add row is the last row of each list, so a list taller than the window hides it below the fold. ⌘N focuses it. Options on the table: pin it under the list as a compose bar, add a `+` toolbar button that scrolls to it, or switch between the two by list length.
