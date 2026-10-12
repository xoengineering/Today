# Today

A calm TODO list app with only two buckets: _Today_ and _Backlog_. Built for macOS, iOS, and iPadOS. As a thin layer on top of the _Reminders_ app.

## Principles

- Calm design with no notifications or badges
- _Today_ and _Backlog_ are the only two buckets
- Today items reset to Backlog at the end of your day
- List ordering stored as metadata in Reminders app
- Minimal dashboard with daily progress rings
- Trinary item states with `to do`, `in progress`, `done`
- Inbox zero is a good thing
- Nothing is stored in _**Today**_ itself
- Syncing uses your existing iCloud settings

---

## How it works

Two lists in _Reminders_, `Today` and `Backlog`, are the buckets. Moving an item between buckets moves the reminder between lists. Marking an item as `done` is a real _Reminders_ completion. Everything else _**Today**_ needs about an item is in one line of JSON at the end of the reminder's notes:

```json
today:{"days":["2026-10-11"],"order":3,"state":"doing","v":1}
```

- `order` is the position in the Today list
- `state` is `todo` or `doing`
- `days` is every day the item sat on the `Today` list, which is what the progress rings are drawn from

The text above that JSON line is yours and is never touched.

## Development

See [doc/DEVELOPMENT.md](doc/DEVELOPMENT.md) for the scripts and [doc/PLAN.md](doc/PLAN.md) for the design.

## License

MIT. See [LICENSE.md](LICENSE.md).
