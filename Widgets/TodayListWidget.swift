import SwiftUI
import WidgetKit

struct TodayListWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "TodayList", provider: TodayListProvider()) { entry in
      TodayListWidgetView(entry: entry)
        .containerBackground(.background, for: .widget)
    }
    .configurationDisplayName("Today")
    .description("The reminders in your Today list.")
    .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
  }
}
