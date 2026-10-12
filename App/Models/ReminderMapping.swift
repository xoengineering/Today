import EventKit
import TodayKit

extension TodayItem {
  /// A reminder read into Today's model, with the list it is in deciding the bucket.
  init(reminder: EKReminder, todayListIdentifier: String) {
    let (body, metadata) = NotesFooter.split(reminder.notes)
    self.init(
      id: reminder.calendarItemIdentifier,
      title: reminder.title ?? "",
      bucket: reminder.calendar?.calendarIdentifier == todayListIdentifier ? .today : .backlog,
      isCompleted: reminder.isCompleted,
      completionDate: reminder.completionDate,
      creationDate: reminder.creationDate,
      body: body,
      metadata: metadata
    )
  }
}

extension EKReminder {
  /// Writes an item's fields onto the reminder, leaving the save to the caller.
  func apply(_ item: TodayItem, todayList: EKCalendar, backlogList: EKCalendar) {
    if title != item.title {
      title = item.title
    }
    // Completion and completionDate are linked. Only touch them when the item disagrees, so a completion
    // recorded by another client keeps its original date.
    if isCompleted != item.isCompleted {
      isCompleted = item.isCompleted
    }
    let notes = NotesFooter.join(body: item.body, metadata: item.metadata)
    if self.notes != notes {
      self.notes = notes
    }
    let list = item.bucket == .today ? todayList : backlogList
    if calendar?.calendarIdentifier != list.calendarIdentifier {
      calendar = list
    }
  }
}
