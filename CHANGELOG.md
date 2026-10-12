# Changelog

All notable changes to Today are documented here.

## Unreleased

- Add `RemindersStore`, the one EventKit adapter: asks for full Reminders access, resolves or creates the Today and Backlog lists, loads both as `TodayItem` values, applies the end-of-day rollover on every load, and reloads on every external change.
- Add the app shell: a sidebar with Today, Backlog, and Rings, lists with the trinary check circle, inline title editing, drag reordering in Today, move between buckets from the context menu or a swipe, delete, an always-present add row, and an empty state for each bucket.
- Add the `TodayKit` core: the notes footer that carries each item's order, state, and day history (`ItemMetadata`, `NotesFooter`), the user-defined `EndOfDay` and the `LogicalDay` it produces, the `TodayItem` model with its trinary `CheckState`, Today list ordering, the end-of-day rollover rule, and the per-day `DayRing` math.
- Initialize the repository: XcodeGen project with an app target for macOS, iOS, and iPadOS, a widget extension target, the `TodayKit` package, scripts, lint configuration, CI workflow, license, and plan.
