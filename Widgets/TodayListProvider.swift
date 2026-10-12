import WidgetKit

struct TodayListEntry: TimelineEntry {
  let date: Date
}

struct TodayListProvider: TimelineProvider {
  func placeholder(in context: Context) -> TodayListEntry {
    TodayListEntry(date: .now)
  }

  func getSnapshot(in context: Context, completion: @escaping (TodayListEntry) -> Void) {
    completion(TodayListEntry(date: .now))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<TodayListEntry>) -> Void) {
    completion(Timeline(entries: [TodayListEntry(date: .now)], policy: .never))
  }
}
