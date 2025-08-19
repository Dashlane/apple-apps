import SwiftUI

public struct DesignSystemButtonStyle: ButtonStyle {
  @Environment(\.style) private var style
  @Environment(\.isEnabled) private var isEnabled
  @Environment(\.controlSize) private var controlSize
  @Environment(\.buttonDisplayProgressIndicator) private var displayProgressIndicator

  @ScaledMetric private var contentScale = 100
  @ScaledMetric private var cornerRadius = 10

  private let labelStyle: LabelStyle

  private var backgroundShape: ButtonShape {
    ButtonShape(cornerRadius: cornerRadius)
  }

  init(_ labelStyle: LabelStyle) {
    self.labelStyle = labelStyle
  }

  public func makeBody(configuration: Configuration) -> some View {
    label(for: configuration)
      .labelStyle(CustomLabelStyle(style: labelStyle))
      .textStyle(.component.button.standard)
      .tint(
        .textTint(style: style, isEnabled: isEnabled) { color in
          return color.opacity(configuration.isPressed ? 0.8 : 1)
        }
      )
      .transformEnvironment(\.style) { style in
        style = Style(
          mood: style.mood,
          intensity: style.intensity == .catchy ? .catchy : .quiet,
          priority: style.priority
        )
      }
      .opacity(displayProgressIndicator ? 0 : 1)
      .scaleEffect(displayProgressIndicator ? 0.7 : 1)
      .overlay {
        if displayProgressIndicator {
          ProgressView()
            .progressViewStyle(IndeterminateProgressViewStyle(invertColors: true))
            .controlSize(.mini)
            .transition(.scale(scale: 0.2).combined(with: .opacity))
        }
      }
      .animation(
        .spring(response: 0.3, dampingFraction: 0.8),
        value: displayProgressIndicator
      )
      .frame(
        maxWidth: labelStyle.extendHorizontally ? .infinity : nil,
        minHeight: controlSize.minimumContentHeight(forContentScale: effectiveContentScale)
      )
      .fixedSize(horizontal: labelStyle.fixedHorizitontally, vertical: false)
      .background(.ds.expressiveContainer, in: .containerRelative)
      .highlighted(configuration.isPressed)
      .accessibilityElement(children: .combine)
      .contentShape(.containerRelative)
      .contentShape(.hoverEffect, backgroundShape)
      .hoverEffect(.highlight, isEnabled: !displayProgressIndicator && isEnabled)
      .containerShape(backgroundShape)
  }

  @ViewBuilder
  private func label(for configuration: Configuration) -> some View {
    if case .titleOnly = labelStyle {
      Label(
        title: { configuration.label },
        icon: { EmptyView() }
      )
    } else {
      configuration.label
    }
  }

  private var effectiveContentScale: Double {
    contentScale / 100
  }
}

extension ControlSize {
  fileprivate func minimumContentHeight(forContentScale contentScale: Double) -> Double {
    switch self {
    case .mini, .small, .regular:
      return 40 * contentScale
    case .large, .extraLarge:
      return 48 * contentScale
    @unknown default:
      return 48 * contentScale
    }
  }
}

private struct CustomLabelStyle: LabelStyle {
  private let style: DesignSystemButtonStyle.LabelStyle

  init(style: DesignSystemButtonStyle.LabelStyle) {
    self.style = style
  }

  func makeBody(configuration: Configuration) -> some View {
    switch style {
    case .iconLeading:
      Label(
        title: { configuration.title },
        icon: { configuration.icon }
      )
      .labelStyle(ButtonTitleAndIconLabelStyle(iconAlignment: .leading))
    case .iconOnly:
      Label(
        title: { EmptyView() },
        icon: { configuration.icon }
      )
      .labelStyle(ButtonIconOnlyLabelStyle())
    case .iconTrailing:
      Label(
        title: { configuration.title },
        icon: { configuration.icon }
      )
      .labelStyle(ButtonTitleAndIconLabelStyle(iconAlignment: .trailing))
    case .titleOnly:
      Label(
        title: { configuration.title },
        icon: { EmptyView() }
      )
      .labelStyle(ButtonTitleOnlyLabelStyle())
    }
  }
}

extension DesignSystemButtonStyle {
  public enum LabelStyle {
    public enum SizingOptions {
      case sizeToFit
      case extend
    }

    case iconLeading(_ sizingOptions: SizingOptions)
    case iconOnly
    case iconTrailing(_ sizingOptions: SizingOptions)
    case titleOnly(_ sizingOptions: SizingOptions)
  }
}

extension DesignSystemButtonStyle.LabelStyle {
  public static var iconLeading: Self {
    .iconLeading(.extend)
  }

  public static var titleOnly: Self {
    .titleOnly(.extend)
  }

  public static var iconTrailing: Self {
    .iconTrailing(.extend)
  }

  var fixedHorizitontally: Bool {
    switch self {
    case .iconOnly:
      return true
    case .iconTrailing, .titleOnly, .iconLeading:
      return false
    }
  }

  var extendHorizontally: Bool {
    switch self {
    case .iconOnly:
      return false
    case let .iconTrailing(sizingOptions),
      let .titleOnly(sizingOptions),
      let .iconLeading(sizingOptions):
      return sizingOptions == .extend
    }
  }
}

extension ButtonStyle where Self == DesignSystemButtonStyle {
  public static func designSystem(_ labelStyle: DesignSystemButtonStyle.LabelStyle) -> Self {
    return DesignSystemButtonStyle(labelStyle)
  }
}

#Preview {
  StylesButtonPreview()
}
