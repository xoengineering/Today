# Changelog

All notable changes to Today are documented here.

## Unreleased

- The Rings title bar spans the whole window, like the other screens, instead of only the grid's width.
- Add `script/index`, which hands Xcode's build settings to sourcekit-lsp through xcode-build-server so editors other than Xcode resolve `TodayKit`, `Testing`, and `PackageDescription`. The `Today` scheme now tests the package.
- The empty Today and Backlog states drop their trailing periods.
- Settings on macOS fits its content with no scrolling, no longer hands keyboard focus to the end-of-day stepper on open, and explains each section in one line.
- Add Settings: the end-of-day time and the two Reminders lists. A Settings window on macOS, a sheet on iOS.
- The empty Today state celebrates when something was finished today, and invites when nothing was planned.
- Add the Rings screen: eight weeks of day rings, green for finished, red for not, gray for days with nothing planned.
- Add the Today widget for macOS, iOS, and iPadOS in small, medium, and large. It reads the Today list from Reminders directly and refreshes at the end of the day and whenever the app saves.
- Add menu commands: New Item (⌘N) focuses the add row, Go to Today, Backlog, and Rings (⌘1, ⌘2, ⌘3).
- Add privacy manifests for the app and the widget. Nothing is tracked and nothing is collected.
- Add `RemindersStore`, the one EventKit adapter: asks for full Reminders access, resolves or creates the Today and Backlog lists, loads both as `TodayItem` values, applies the end-of-day rollover on every load, and reloads on every external change.
- Add the app shell: a sidebar with Today, Backlog, and Rings, lists with the trinary check circle, inline title editing, drag reordering in Today, move between buckets from the context menu or a swipe, delete, an always-present add row, and an empty state for each bucket.
- Add the `TodayKit` core: the notes footer that carries each item's order, state, and day history (`ItemMetadata`, `NotesFooter`), the user-defined `EndOfDay` and the `LogicalDay` it produces, the `TodayItem` model with its trinary `CheckState`, Today list ordering, the end-of-day rollover rule, and the per-day `DayRing` math.
- Initialize the repository: XcodeGen project with an app target for macOS, iOS, and iPadOS, a widget extension target, the `TodayKit` package, scripts, lint configuration, CI workflow, license, and plan.
