import SwiftUI

public struct Badge: View {
  @Environment(\.style) private var style
  @Environment(\.iconAlignment) private var iconAlignment

  @ScaledMetric private var iconDimension = 12
  @ScaledMetric private var backgroundCornerRadius = 2
  @ScaledMetric private var textHorizontalPadding = 2
  @ScaledMetric private var containerPadding = 4

  private let title: String
  private let icon: Image?

  public init(_ title: String, icon: Image? = nil) {
    self.title = title
    self.icon = icon
  }

  public var body: some View {
    HStack(spacing: 0) {
      if let icon, iconAlignment == .leading {
        makeIconView(icon: icon)
      }
      Text(title)
        .textStyle(.component.badge.standard)
        .lineLimit(1)
        .padding(.horizontal, textHorizontalPadding)
      if let icon, iconAlignment == .trailing {
        makeIconView(icon: icon)
      }
    }
    ._foregroundStyle(.text)
    .transformEnvironment(\.style) { style in
      style = Style(
        mood: style.mood,
        intensity: style.intensity == .catchy ? .catchy : .quiet,
        priority: style.priority
      )
    }
    .padding(containerPadding)
    .background(backgroundView)
    .accessibilityElement()
    .accessibilityLabel(Text(title))
  }

  @ViewBuilder
  private var backgroundView: some View {
    if let borderColor = Color.borderColor(for: style) {
      RoundedRectangle(cornerRadius: backgroundCornerRadius, style: .continuous)
        .stroke(borderColor, lineWidth: 1)
    } else {
      RoundedRectangle(cornerRadius: backgroundCornerRadius, style: .continuous)
        ._foregroundStyle(.expressiveContainer)
    }
  }

  private func makeIconView(icon: Image) -> some View {
    icon
      .resizable()
      .frame(width: iconDimension, height: iconDimension)
  }
}

extension Color {
  fileprivate static func borderColor(for style: Style) -> Color? {
    guard case .supershy = style.intensity else { return nil }
    switch style.mood {
    case .neutral:
      return .ds.border.neutral.quiet.idle
    case .brand:
      return .ds.border.brand.quiet.idle
    case .danger:
      return .ds.border.danger.quiet.idle
    case .positive:
      return .ds.border.positive.quiet.idle
    case .warning:
      return .ds.border.warning.quiet.idle
    }
  }
}

#Preview {
  BadgePreview()
}
