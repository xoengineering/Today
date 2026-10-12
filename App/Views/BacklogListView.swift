import SwiftUI
import TodayKit

/// Everything that is not today.
struct BacklogListView: View {
  @Environment(RemindersStore.self) private var store
  @Environment(NavigationState.self) private var navigation

  var body: some View {
    List {
      ForEach(store.backlogItems) { item in
        ItemRow(item: item)
      }
      AddItemField(bucket: .backlog)
    }
    .id(store.backlogListIdentity)
    .overlay {
      if store.backlogItems.isEmpty {
        EmptyBucketView(bucket: .backlog)
          .allowsHitTesting(false)
      }
    }
    .listStyle(.plain)
    .onTapGesture { navigation.requestDismissFocus() }
    .scrollDismissesKeyboard(.immediately)
    .navigationTitle("Backlog")
    .toolbarTitleDisplayMode(.inline)
  }
}
