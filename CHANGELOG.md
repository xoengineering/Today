# Changelog

All notable changes to Today are documented here.

## Unreleased

- Add the `TodayKit` core: the notes footer that carries each item's order, state, and day history (`ItemMetadata`, `NotesFooter`), the user-defined `EndOfDay` and the `LogicalDay` it produces, the `TodayItem` model with its trinary `CheckState`, Today list ordering, the end-of-day rollover rule, and the per-day `DayRing` math.
- Initialize the repository: XcodeGen project with an app target for macOS, iOS, and iPadOS, a widget extension target, the `TodayKit` package, scripts, lint configuration, CI workflow, license, and plan.
