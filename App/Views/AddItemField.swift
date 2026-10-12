import SwiftUI
import TodayKit

/// The always-present last row, where typing and pressing return creates the item.
struct AddItemField: View {
  @Environment(RemindersStore.self) private var store
  @Environment(NavigationState.self) private var navigation
  let bucket: Bucket
  @State private var title = ""
  @FocusState private var isFocused: Bool

  var body: some View {
    HStack(alignment: .top, spacing: 8) {
      Button {
        isFocused = true
      } label: {
        Image(systemName: "plus.circle")
          .scaledFont(.title3)
          .foregroundStyle(.tertiary)
      }
      .buttonStyle(.plain)
      .accessibilityLabel(prompt)
      // A field in a table row never reports a wrapped height. The invisible text behind it does,
      // so the row grows with what is typed and the field fills the room.
      ZStack(alignment: .topLeading) {
        Text(title.isEmpty ? prompt : title)
          .scaledFont(.body)
          .fixedSize(horizontal: false, vertical: true)
          .frame(maxWidth: .infinity, alignment: .leading)
          .opacity(0)
          .accessibilityHidden(true)
        TextField(prompt, text: $title, axis: .vertical)
          .scaledFont(.body)
          .textFieldStyle(.plain)
          .focused($isFocused)
          .submitLabel(.done)
          .onSubmit(add)
          // On iOS, Return in a growing field inserts a newline instead of submitting. A newline means submit here.
          .onChange(of: title) { _, newTitle in
            if newTitle.contains("\n") {
              title = newTitle.replacingOccurrences(of: "\n", with: "")
              add()
            }
          }
      }
    }
    .listRowSeparator(.hidden)
    .onChange(of: navigation.addItemRequest) {
      isFocused = true
    }
    .onChange(of: navigation.dismissFocusRequest) {
      isFocused = false
    }
  }

  private var prompt: String {
    bucket == .today ? "Add to Today" : "Add to Backlog"
  }

  private func add() {
    let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
    // Return on an empty field means "never mind": the field lets go, and on iOS the keyboard goes with it.
    guard !trimmed.isEmpty else {
      title = ""
      isFocused = false
      return
    }
    store.add(title: trimmed, to: bucket)
    title = ""
    isFocused = true
  }
}
