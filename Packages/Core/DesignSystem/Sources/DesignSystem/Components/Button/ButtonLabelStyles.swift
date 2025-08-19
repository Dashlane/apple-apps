import SwiftUI

struct ButtonIconOnlyLabelStyle: LabelStyle {
  @ScaledMetric private var iconDimension = 20
  @ScaledMetric private var contentScale = 100

  @Environment(\.controlSize) private var controlSize

  func makeBody(configuration: Configuration) -> some View {
    configuration.icon
      .foregroundStyle(.tint)
      .frame(width: iconDimension, height: iconDimension)
      .padding(.all, padding * effectiveContentScale)
  }

  private var padding: Double {
    switch controlSize {
    case .mini, .small, .regular:
      return 10
    case .large, .extraLarge:
      return 14
    @unknown default:
      return 14
    }
  }

  private var effectiveContentScale: Double {
    contentScale / 100
  }
}

struct ButtonTitleOnlyLabelStyle: LabelStyle {
  @Environment(\.controlSize) private var controlSize

  @ScaledMetric private var contentScale = 100

  func makeBody(configuration: Configuration) -> some View {
    configuration.title
      .foregroundStyle(.tint)
      .padding(padding)
  }

  private var padding: EdgeInsets {
    switch controlSize {
    case .mini, .small:
      return EdgeInsets(
        top: 10 * effectiveContentScale,
        leading: 14 * effectiveContentScale,
        bottom: 10 * effectiveContentScale,
        trailing: 14 * effectiveContentScale
      )
    case .regular, .large:
      fallthrough
    @unknown default:
      return EdgeInsets(
        top: 14 * effectiveContentScale,
        leading: 18 * effectiveContentScale,
        bottom: 14 * effectiveContentScale,
        trailing: 18 * effectiveContentScale
      )
    }
  }

  private var effectiveContentScale: Double {
    contentScale / 100
  }
}

struct ButtonTitleAndIconLabelStyle: LabelStyle {
  @Environment(\.controlSize) private var controlSize

  @ScaledMetric private var iconDimension = 20
  @ScaledMetric private var contentScale = 100

  private let iconAlignment: IconAlignment

  init(iconAlignment: IconAlignment) {
    self.iconAlignment = iconAlignment
  }

  func makeBody(configuration: Configuration) -> some View {
    HStack(alignment: .center, spacing: 8 * effectiveContentScale) {
      if iconAlignment == .leading {
        iconView(for: configuration)
      }
      configuration.title
      if iconAlignment == .trailing {
        iconView(for: configuration)
      }
    }
    .foregroundStyle(.tint)
    .padding(padding)
  }

  private func iconView(for configuration: Configuration) -> some View {
    configuration.icon
      .frame(width: iconDimension, height: iconDimension)
  }

  private var padding: EdgeInsets {
    switch controlSize {
    case .mini, .small:
      return EdgeInsets(
        top: 10 * effectiveContentScale,
        leading: 14 * effectiveContentScale,
        bottom: 10 * effectiveContentScale,
        trailing: 14 * effectiveContentScale
      )
    case .regular, .large:
      fallthrough
    @unknown default:
      return EdgeInsets(
        top: 14 * effectiveContentScale,
        leading: 18 * effectiveContentScale,
        bottom: 14 * effectiveContentScale,
        trailing: 18 * effectiveContentScale
      )
    }
  }

  private var effectiveContentScale: Double {
    contentScale / 100
  }
}
