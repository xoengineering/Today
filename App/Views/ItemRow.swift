import SwiftUI
import TodayKit

/// One reminder, as its circle and its title, which edits in place.
struct ItemRow: View {
  @Environment(RemindersStore.self) private var store
  let item: TodayItem
  @State private var title: String

  init(item: TodayItem) {
    self.item = item
    _title = State(initialValue: item.title)
  }

  var body: some View {
    HStack(spacing: 12) {
      CheckCircle(state: item.checkState) {
        withAnimation {
          store.set(item, to: item.checkState.next)
        }
      }
      TextField("Title", text: $title)
        .textFieldStyle(.plain)
        .strikethrough(item.checkState == .done)
        .foregroundStyle(item.checkState == .done ? .secondary : .primary)
        .onSubmit { store.rename(item, to: title) }
    }
    .padding(.vertical, 4)
    .onChange(of: item.title) { _, newTitle in
      title = newTitle
    }
    .contextMenu {
      moveButton
      Divider()
      Button("Delete", role: .destructive) { store.delete(item) }
    }
    .swipeActions(edge: .leading, allowsFullSwipe: true) {
      moveButton.tint(.accentColor)
    }
    .swipeActions(edge: .trailing) {
      Button("Delete", role: .destructive) { store.delete(item) }
    }
  }

  @ViewBuilder private var moveButton: some View {
    switch item.bucket {
    case .today:
      Button("Move to Backlog", systemImage: "tray.and.arrow.down") { store.moveToBacklog(item) }
    case .backlog:
      Button("Move to Today", systemImage: "sun.max") { store.moveToToday(item) }
    }
  }
}
