import SwiftUI
import TodayKit

/// The Today bucket, in the user's order.
struct TodayListView: View {
  @Environment(RemindersStore.self) private var store
  @Environment(NavigationState.self) private var navigation

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
    // The table keeps row heights it measured earlier. A new identity makes it measure every row again:
    // when the text settings change, and once the first load fills a table that was built empty.
    .id(store.listIdentity)
    .overlay {
      if store.todayItems.isEmpty {
        EmptyBucketView(bucket: .today)
          .allowsHitTesting(false)
      }
    }
    .listStyle(.plain)
    // A tap on the list's empty area drops focus. Taps on rows are claimed by the rows first.
    .onTapGesture { navigation.requestDismissFocus() }
    .scrollDismissesKeyboard(.immediately)
    .navigationTitle("Today")
    .toolbarTitleDisplayMode(.inline)
  }
}
