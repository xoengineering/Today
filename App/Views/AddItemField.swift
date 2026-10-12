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
    HStack(spacing: 12) {
      Button {
        isFocused = true
      } label: {
        Image(systemName: "plus.circle")
          .scaledFont(.title3)
          .foregroundStyle(.tertiary)
      }
      .buttonStyle(.plain)
      .accessibilityLabel(prompt)
      TextField(prompt, text: $title)
        .scaledFont(.body)
        .textFieldStyle(.plain)
        .focused($isFocused)
        .onSubmit(add)
    }
    .padding(.vertical, 4)
    .listRowSeparator(.hidden)
    .onChange(of: navigation.addItemRequest) {
      isFocused = true
    }
  }

  private var prompt: String {
    bucket == .today ? "Add to Today" : "Add to Backlog"
  }

  private func add() {
    let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return }
    store.add(title: trimmed, to: bucket)
    title = ""
    isFocused = true
  }
}
