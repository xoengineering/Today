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
    HStack(alignment: .top, spacing: 8) {
      CheckCircle(
        state: item.checkState,
        advance: { store.set(item, to: item.checkState.next) },
        retreat: { store.set(item, to: item.checkState.previous) })
      if isEditing {
        // A field in a table row never reports a wrapped height. The invisible text behind it does,
        // so the row grows with what is typed and the field fills the room.
        ZStack(alignment: .topLeading) {
          Text(title.isEmpty ? " " : title)
            .scaledFont(.body)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .opacity(0)
            .accessibilityHidden(true)
          TextField("Title", text: $title, axis: .vertical)
            .scaledFont(.body)
            .textFieldStyle(.plain)
            .focused($isFieldFocused)
            .submitLabel(.done)
            .onSubmit(commit)
            // On iOS, Return in a growing field inserts a newline instead of submitting. A newline means commit here.
            .onChange(of: title) { _, newTitle in
              if newTitle.contains("\n") {
                title = newTitle.replacingOccurrences(of: "\n", with: "")
                commit()
              }
            }
            .onChange(of: isFieldFocused) { _, focused in
              if !focused { commit() }
            }
            .onAppear { isFieldFocused = true }
        }
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
    // The separator would run under the baseline, through the circle's bottom and every descender.
    .listRowSeparator(.hidden)
    .onChange(of: item.title) { _, newTitle in
      title = newTitle
    }
    .contextMenu {
      Group {
        stateButtons
        Divider()
        moveButton
        Divider()
        Button("Delete", systemImage: "xmark", role: .destructive) { store.delete(item) }
      }
      // Menus drop the symbols unless asked for both.
      .labelStyle(.titleAndIcon)
    }
    // Swipe actions are icon only. The titles still name them for accessibility.
    // Backward moves are on the leading edge, forward moves on the trailing edge. The first button sits at the edge.
    .swipeActions(edge: .leading, allowsFullSwipe: true) {
      moveButton
        .tint(.accentColor)
        .labelStyle(.iconOnly)
      stateButtons(for: statesBefore)
        .labelStyle(.iconOnly)
    }
    .swipeActions(edge: .trailing) {
      Button("Delete", systemImage: "xmark", role: .destructive) { store.delete(item) }
        .labelStyle(.iconOnly)
      stateButtons(for: statesAfter.reversed())
        .labelStyle(.iconOnly)
    }
  }

  private var statesBefore: [CheckState] {
    Array(CheckState.allCases.prefix { $0 != item.checkState })
  }

  private var statesAfter: [CheckState] {
    Array(CheckState.allCases.drop { $0 != item.checkState }.dropFirst())
  }

  /// The two states the item is not in.
  @ViewBuilder private var stateButtons: some View {
    stateButtons(for: statesBefore + statesAfter)
  }

  @ViewBuilder private func stateButtons(for states: [CheckState]) -> some View {
    ForEach(states, id: \.self) { state in
      // Swipe actions fill their symbols, which turns the empty circle into a disc. The dashed circle has
      // no filled form to fall into, and reads as not started. They also ignore transforms on the icon,
      // so the half-filled one stays upright here.
      let symbol = state == .todo ? "circle.dashed" : state.symbol
      Button("Mark as \(state.label)", systemImage: symbol) { store.set(item, to: state) }
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
