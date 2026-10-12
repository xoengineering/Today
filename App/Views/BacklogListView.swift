import SwiftUI
import TodayKit

/// Everything that is not today.
struct BacklogListView: View {
  @Environment(RemindersStore.self) private var store

  var body: some View {
    List {
      ForEach(store.backlogItems) { item in
        ItemRow(item: item)
      }
      AddItemField(bucket: .backlog)
    }
    .environment(\.defaultMinListRowHeight, 32)
    .overlay {
      if store.backlogItems.isEmpty {
        EmptyBucketView(bucket: .backlog)
          .allowsHitTesting(false)
      }
    }
    .navigationTitle("Backlog")
  }
}
