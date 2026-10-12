import SwiftUI
import TodayKit

/// The Today bucket, in the user's order.
struct TodayListView: View {
  @Environment(RemindersStore.self) private var store

  var body: some View {
    List {
      ForEach(store.todayItems) { item in
        ItemRow(item: item)
      }
      .onMove { source, destination in
        store.moveTodayItems(fromOffsets: source, toOffset: destination)
      }
      AddItemField(bucket: .today)
    }
    // A known row height, so newly inserted rows are never laid out from a stale estimate and overlap.
    .environment(\.defaultMinListRowHeight, 32)
    .overlay {
      if store.todayItems.isEmpty {
        EmptyBucketView(bucket: .today)
          .allowsHitTesting(false)
      }
    }
    .navigationTitle("Today")
  }
}
