import SwiftUI

struct ModifierPreview<Content: View>: View {
  let modifier: PreviewedModifier

  @ViewBuilder let content: () -> Content

  init(modifier: PreviewedModifier, @ViewBuilder content: @escaping () -> Content) {
    self.modifier = modifier
    self.content = content
  }

  var body: some View {
    Grid(alignment: .leading, verticalSpacing: 20) {
      modifier.forEach { name in
        GridRow {
          Text(name)
            .foregroundStyle(.secondary)
            .font(.caption)
          content()
        }
      }
    }
    .padding()
  }
}

#Preview(traits: .sizeThatFitsLayout) {
  ModifierPreview(modifier: .mood) {
    RoundedRectangle(cornerRadius: 12, style: .continuous)
      .frame(width: 30, height: 30)
      .foregroundStyle(.ds.expressiveContainer)
  }
}
