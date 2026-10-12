# Changelog

All notable changes to Today are documented here.

## Unreleased

- Sidebar symbols take the text color, and the empty-state art is gray.
- A tap on a list's empty area, Return on an empty add field, or a scroll drops field focus, which on iOS dismisses the keyboard.
- The end-of-day setting has its own header, with the row named Reset time.
- Rings rows are laid out like item rows, with a symbol for the day in place of the drawn ring: gray dotted for nothing planned, red dashed for nothing done, a green arc for the share done, and a green checked disc for everything done.
- Launching with `-fakeRings` shows one synthetic day per tenth on the Rings screen, for looking at the symbols.
- Titles stay in the title bar on iOS, and lists are plain rows on the background rather than cards. Rings rows have no separators.
- Settings panes show their content on iOS.
- Rows use each platform's own list insets. Only the 8 points between a circle and its text is set by the app.
- On iOS, Return submits the add field and commits a title edit instead of inserting a newline.
- `script/run device` builds, installs, and launches on a paired iPhone or iPad.
- Rows use the same 8 points between the circle and the text as between one row and the next, and day rings draw their stroke inside their box so they line up with the item circles.
- Day rings grow with the text size more gently than the text itself.
- Every menu and context menu item carries a symbol.
- Swipe actions are split by direction: Move and earlier states on the leading edge, later states and Delete on the trailing edge.
- Any state is one step away: ⌥-click or ⌘-click a circle to step back, and the context menu and trailing swipe offer the two states an item is not in. Clicks stop at the ends rather than wrapping around, so a modified click on an unstarted item no longer completes it.
- The selected sidebar row shows its filled symbol.
- Rings rows keep the date on one line and drop the finished count when there isn't room. "(Today)" and "(Yesterday)" are part of the date string.
- Lists re-measure their rows when the text size or typeface changes and after the first load at launch, so rows never keep a stale height.
- The in-progress circle is split from bottom left to top right, and the three states crossfade with the half-filled one swinging into place on a small spring.
- Swipe actions show icons only, with an X for Delete.
- The add row and a title being edited grow with their text instead of scrolling sideways.
- Settings has General and Appearance tabs. Text size gains a sixth step, Giant.
- Add a typeface setting: Sans, Rounded, Serif, or Mono, picked from four tiles that each show their own face.
- Text size is a slider in Settings. The sidebar is a fixed width, toggle only.
- Add a text size setting with five steps, in Settings and as Bigger Text (⌘+) and Smaller Text (⌘-) in the View menu. Rows, circles, and rings scale with it.
- Titles show as wrapping text and become a field on click, so rows grow with long titles and larger text.
- The window is at least 600 by 320, and the content takes whatever width the sidebar leaves, so nothing is pushed off the window's edges.
- Window tabbing is off on macOS, so the View and Window menus no longer offer tabs.
- The plus in the add row is a button that puts the cursor in the field.
- List rows have no separator lines, land at their final height when inserted, and wrap long titles instead of truncating them.
- The sidebar is between 160 and 280 points wide and the content area is at least 400.
- Rings is a list, newest day first, from today back to the first day anything was on the Today list. Each row shows the ring, the date, "Today" or "Yesterday" when it applies, and how many of that day's items were finished.
- Add a date format setting for the Rings list: System, ISO 8601, Long, Weekday and long, or Numeric.
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
