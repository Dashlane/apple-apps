import SwiftUI

struct ModifierPreviewGrid<Content: View>: View {
  let horizontalAxis: PreviewedModifier
  let veriticalAxis: PreviewedModifier

  @ViewBuilder let content: () -> Content

  init(
    horizontalAxis: PreviewedModifier, veriticalAxis: PreviewedModifier,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.horizontalAxis = horizontalAxis
    self.veriticalAxis = veriticalAxis
    self.content = content
  }

  var body: some View {
    Grid {
      GridRow {
        Text("")
        horizontalAxis.forEach { name in
          Text(name)
            .foregroundStyle(.secondary)
            .font(.caption)
        }
      }

      veriticalAxis.forEach { name in
        GridRow {
          Text(name)
            .foregroundStyle(.secondary)
            .font(.caption)

          horizontalAxis.forEach { _ in
            content()
          }
        }
      }
    }
    .padding()
  }
}

#Preview("PreviewComponent", traits: .sizeThatFitsLayout) {
  ModifierPreviewGrid(horizontalAxis: .intensity, veriticalAxis: .mood) {
    RoundedRectangle(cornerRadius: 12, style: .continuous)
      .frame(width: 30, height: 30)
      .foregroundStyle(.ds.expressiveContainer)
  }
}
