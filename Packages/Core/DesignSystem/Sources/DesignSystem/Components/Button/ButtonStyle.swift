import SwiftUI

struct _DesignSystemMenuStyle: MenuStyle {
  @Environment(\.controlSize) private var controlSize
  @Environment(\.isEnabled) private var isEnabled
  @Environment(\.style) private var style

  @ScaledMetric private var contentScale = 100

  func makeBody(configuration: Configuration) -> some View {
    Menu(configuration)
      .labelStyle(CustomLabelStyle(style: .iconLeading))
      .textStyle(.component.button.standard)
      .tint(.textTint(style: style, isEnabled: isEnabled))
      .transformEnvironment(\.style) { style in
        style = Style(
          mood: style.mood,
          intensity: style.intensity == .catchy ? .catchy : .quiet,
          priority: style.priority
        )
      }
      .frame(
        minHeight: controlSize.minimumContentHeight(forContentScale: effectiveContentScale)
      )
      .frame(maxWidth: .infinity)
      .background(ButtonBackgroundView())
      .contentShape(Rectangle())
  }

  private var effectiveContentScale: Double {
    contentScale / 100
  }
}

public struct DesignSystemButtonStyle: ButtonStyle {
  @Environment(\.style) private var style
  @Environment(\.isEnabled) private var isEnabled
  @Environment(\.controlSize) private var controlSize
  @Environment(\.buttonDisplayProgressIndicator) private var displayProgressIndicator

  @ScaledMetric private var contentScale = 100

  private let labelStyle: LabelStyle

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
        minHeight: controlSize.minimumContentHeight(forContentScale: effectiveContentScale)
      )
      .frame(maxWidth: .infinity)
      .fixedSize(horizontal: labelStyle == .iconOnly, vertical: false)
      .background(ButtonBackgroundView())
      .highlighted(configuration.isPressed)
      .contentShape(Rectangle())
      .accessibilityElement(children: .combine)
  }

  @ViewBuilder
  private func label(for configuration: Configuration) -> some View {
    if labelStyle == .titleOnly {
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

private struct ButtonBackgroundView: View {
  @ScaledMetric private var cornerRadius = 10

  var body: some View {
    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
      ._foregroundStyle(.expressiveContainer)
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

extension ButtonStyle where Self == DesignSystemButtonStyle {
  public static func designSystem(_ labelStyle: DesignSystemButtonStyle.LabelStyle) -> Self {
    return DesignSystemButtonStyle(labelStyle)
  }
}

extension ControlSize {
  fileprivate func minimumContentHeight(forContentScale contentScale: Double) -> Double {
    switch self {
    case .mini, .small:
      return 40 * contentScale
    case .regular, .large:
      fallthrough
    @unknown default:
      return 48 * contentScale
    }
  }
}

extension DesignSystemButtonStyle {
  public enum LabelStyle {
    case iconLeading
    case iconOnly
    case iconTrailing
    case titleOnly
  }
}

#Preview {
  StylesButtonPreview()
}
