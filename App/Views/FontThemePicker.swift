import SwiftUI
import TodayKit

/// Four tiles, one per typeface, each drawn in its own face, with the chosen one outlined in the accent color.
struct FontThemePicker: View {
  @Binding var selection: FontTheme

  var body: some View {
    HStack(spacing: 8) {
      ForEach(FontTheme.allCases, id: \.self) { theme in
        Button {
          selection = theme
        } label: {
          VStack(spacing: 4) {
            Text("Aa")
              .font(.system(size: 24, design: theme.design))
            Text(theme.label)
              .font(.system(.caption, design: theme.design))
              .foregroundStyle(.secondary)
          }
          .frame(maxWidth: .infinity)
          .padding(.vertical, 10)
          .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
          .overlay {
            RoundedRectangle(cornerRadius: 8)
              .strokeBorder(selection == theme ? Color.accentColor : .clear, lineWidth: 2)
          }
          .contentShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(theme.label)
        .accessibilityAddTraits(selection == theme ? .isSelected : [])
      }
    }
  }
}
