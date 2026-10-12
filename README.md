# Today

A calm TODO app with two buckets: Today and Backlog.

For macOS, iOS, and iPadOS. It is a view on top of Apple Reminders. Your reminders are the data, synced by your own iCloud. Today stores nothing of its own.

## Principles

- Two buckets only. Today, and everything else.
- Today items can be reordered.
- The Today list resets at the end of your day, and you decide when that is (4am counts).
- Reaching an empty Today or Backlog is a moment worth celebrating.
- Calm. No badges, no notifications, no nagging.
- The only measure is a ring per day: did you finish what you put on your Today list?
- Each item has three states: to do, in progress, done.
- Widgets show your Today list.

## Development

- macOS, iOS, and iPadOS 27 or later. Swift 6.4 or later. SwiftUI. Swift Testing.
- `script/setup` installs tools, generates `Today.xcodeproj` (XcodeGen), and creates `Local.xcconfig` from the example. Set `DEVELOPMENT_TEAM` in it to your Apple Developer Team ID. It is gitignored, so no one's team ID is in the repo.
- `script/test` runs the TodayKit test suite.
- `script/build [macos|ios]` builds the app.
- `script/lint` and `script/format` run swift format and SwiftLint.
- `script/run` builds and launches the macOS app.
- `script/run ios` builds, installs, and launches in the iOS Simulator. Takes an optional simulator name: `script/run ios "iPad Pro 11-inch (M5)"`. Only iOS 27 simulators are eligible. Grant the simulator app Reminders access without the prompt with `xcrun simctl privacy booted grant reminders engineering.xo.Today`.

## How it works

Today owns no data. Two lists in Reminders, Today and Backlog, are the buckets. Moving an item between buckets moves the reminder between lists. Done is a real Reminders completion. Everything else Today knows about an item lives in one line at the end of the reminder's notes:

```txt
today:{"days":["2026-10-11"],"order":3,"state":"doing","v":1}
```

`order` is the position in the Today list, `state` is `todo` or `doing`, and `days` is every day the item sat on the Today list, which is what the rings are drawn from. The text above that line is yours and is never touched.

To run on a physical iPhone or iPad, open `Today.xcodeproj` in Xcode, pick the device as the destination, and Run. The device needs Developer Mode enabled and `DEVELOPMENT_TEAM` set in `Local.xcconfig`.

## License

MIT. See [LICENSE.md](LICENSE.md).
