import Foundation

/// A reminder as Today sees it.
///
/// The app builds these from EventKit and writes changes back.
public struct TodayItem: Identifiable, Hashable, Sendable {
  public let id: String
  public var title: String
  public var bucket: Bucket
  public var isCompleted: Bool
  public var completionDate: Date?
  public var creationDate: Date?
  /// The user's own notes, without the app's footer.
  public var body: String
  /// Nil when the reminder has no footer yet.
  public var metadata: ItemMetadata?

  public init(
    id: String,
    title: String,
    bucket: Bucket,
    isCompleted: Bool = false,
    completionDate: Date? = nil,
    creationDate: Date? = nil,
    body: String = "",
    metadata: ItemMetadata? = nil
  ) {
    self.id = id
    self.title = title
    self.bucket = bucket
    self.isCompleted = isCompleted
    self.completionDate = completionDate
    self.creationDate = creationDate
    self.body = body
    self.metadata = metadata
  }

  public var checkState: CheckState {
    if isCompleted { return .done }
    return metadata?.state == .doing ? .doing : .todo
  }

  public var order: Int? { metadata?.order }

  /// The item with its circle moved to a state.
  ///
  /// Completion is real Reminders completion.
  public func setting(_ state: CheckState, completedAt date: Date = .now) -> Self {
    var item = self
    var metadata = item.metadata ?? ItemMetadata()
    switch state {
    case .todo:
      item.isCompleted = false
      item.completionDate = nil
      metadata.state = .todo
    case .doing:
      item.isCompleted = false
      item.completionDate = nil
      metadata.state = .doing
    case .done:
      item.isCompleted = true
      item.completionDate = date
      metadata.state = .todo
    }
    item.metadata = metadata
    return item
  }

  /// The item placed on the Today list for a day, with the day recorded in its history.
  public func movedToToday(on day: LogicalDay, order: Int) -> Self {
    var item = self
    var metadata = item.metadata ?? ItemMetadata()
    if metadata.days.last != day {
      metadata.days.append(day)
    }
    metadata.order = order
    item.metadata = metadata
    item.bucket = .today
    return item
  }

  /// The item returned to the Backlog.
  ///
  /// Its history stays, its position and progress do not.
  public func movedToBacklog() -> Self {
    var item = self
    if var metadata = item.metadata {
      metadata.order = nil
      metadata.state = .todo
      item.metadata = metadata
    }
    item.bucket = .backlog
    return item
  }
}
