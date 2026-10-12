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
    // The table keeps row heights it measured earlier. A new identity makes it measure every row again.
    .id(store.settings.textSize.rawValue + store.settings.fontTheme.rawValue)
    .overlay {
      if store.todayItems.isEmpty {
        EmptyBucketView(bucket: .today)
          .allowsHitTesting(false)
      }
    }
    .navigationTitle("Today")
  }
}
