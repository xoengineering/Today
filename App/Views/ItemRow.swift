import SwiftUI
import TodayKit

/// One reminder, as its circle and its title, which edits in place.
///
/// The title shows as text, which wraps and sizes its row. A click swaps in a field. Return or leaving commits.
struct ItemRow: View {
  @Environment(RemindersStore.self) private var store
  let item: TodayItem
  @State private var title: String
  @State private var isEditing = false
  @FocusState private var isFieldFocused: Bool

  init(item: TodayItem) {
    self.item = item
    _title = State(initialValue: item.title)
  }

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      CheckCircle(state: item.checkState) {
        withAnimation {
          store.set(item, to: item.checkState.next)
        }
      }
      if isEditing {
        TextField("Title", text: $title)
          .scaledFont(.body)
          .textFieldStyle(.plain)
          .focused($isFieldFocused)
          .onSubmit(commit)
          .onChange(of: isFieldFocused) { _, focused in
            if !focused { commit() }
          }
          .onAppear { isFieldFocused = true }
      } else {
        Text(item.title)
          .scaledFont(.body)
          .strikethrough(item.checkState == .done)
          .foregroundStyle(item.checkState == .done ? .secondary : .primary)
          .fixedSize(horizontal: false, vertical: true)
          .frame(maxWidth: .infinity, alignment: .leading)
          .contentShape(Rectangle())
          .onTapGesture { isEditing = true }
      }
    }
    .padding(.vertical, 4)
    // The separator would run under the baseline, through the circle's bottom and every descender.
    .listRowSeparator(.hidden)
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

  private func commit() {
    isEditing = false
    store.rename(item, to: title)
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
