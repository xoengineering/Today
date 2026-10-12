# Findings

Platform quirks, SDK gotchas, and tool behaviors met while building Today. Each entry describes the mechanism as it is, so a future reader can act on it without the history.

## EventKit

- There is no public API for Reminders tags, flags, attachments, subtasks, sections, or manual sort order. The full surface is `EKReminder`, `EKCalendarItem`, `EKCalendar`, and `EKEventStore` as listed in `PLAN.md` §1.
- `saveReminder` and `removeReminder` are prohibited on watchOS. A watch app could only read.
