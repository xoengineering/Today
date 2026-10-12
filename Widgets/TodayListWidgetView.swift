import SwiftUI
import TodayKit
import WidgetKit

struct TodayListWidgetView: View {
  @Environment(\.widgetFamily) private var family
  let entry: TodayListEntry

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text("Today")
        .font(.headline)
      if !entry.hasAccess {
        Text("Open Today to allow Reminders access.")
          .font(.caption)
          .foregroundStyle(.secondary)
      } else if entry.items.isEmpty {
        Text("Nothing left for today.")
          .font(.caption)
          .foregroundStyle(.secondary)
      } else {
        ForEach(entry.items.prefix(rowLimit)) { item in
          HStack(spacing: 6) {
            Image(systemName: item.checkState == .doing ? "circle.lefthalf.filled" : "circle")
              .foregroundStyle(item.checkState == .doing ? Color.accentColor : .secondary)
            Text(item.title)
              .lineLimit(1)
          }
          .font(.caption)
        }
        if entry.items.count > rowLimit {
          Text("and \(entry.items.count - rowLimit) more")
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
      }
      Spacer(minLength: 0)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var rowLimit: Int {
    switch family {
    case .systemSmall: 3
    case .systemMedium: 4
    default: 10
    }
  }
}
