import SwiftUI

public struct DisplayFieldGenericTextLabelStyle: LabelStyle {
  @Environment(\.style.accessoryIcon) private var accessoryIcon
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  @ScaledMetric private var accessoryIconDimension = 16
  @ScaledMetric private var spacing = 4

  public func makeBody(configuration: Configuration) -> some View {
    HStack(alignment: .center, spacing: spacing) {
      if let accessoryIcon = accessoryIcon {
        accessoryIcon
          .resizable()
          .frame(width: accessoryIconDimension, height: accessoryIconDimension)
      }
      configuration.icon
        .frame(width: accessoryIconDimension, height: accessoryIconDimension)
      configuration.title
        .textStyle(.body.standard.regular)
    }
    .foregroundStyle(
      .ds.text.overriding { @Sendable environment, color in
        if environment.isEnabled, environment.style.mood == .neutral {
          .ds.text.neutral.catchy
        } else {
          color
        }
      }
    )
    .transformEnvironment(\.style) { style in
      guard style.mood != .neutral else { return }
      style = .init(mood: style.mood, intensity: .supershy, priority: style.priority)
    }
    .style(mood: .neutral, priority: .low)
  }
}

extension Style {
  var accessoryIcon: Image? {
    return switch mood {
    case .brand, .neutral:
      nil
    case .warning:
      .ds.feedback.warning.outlined
    case .danger:
      .ds.feedback.fail.outlined
    case .positive:
      .ds.feedback.success.outlined
    }
  }
}

extension LabelStyle where Self == DisplayFieldGenericTextLabelStyle {
  public static var displayFieldGenericText: Self { DisplayFieldGenericTextLabelStyle() }
}

#Preview {
  VStack(spacing: 16) {
    Label(
      title: { Text("This is my content!") },
      icon: { EmptyView() }
    )
    .labelStyle(.displayFieldGenericText)

    Label(
      title: { Text("This is my content!") },
      icon: { EmptyView() }
    )
    .labelStyle(.displayFieldGenericText)
    .style(.warning)

    Label(
      title: { Text("This is my content!") },
      icon: { EmptyView() }
    )
    .labelStyle(.displayFieldGenericText)
    .style(.error)

    Label(
      title: { Text("This is my content!") },
      icon: { EmptyView() }
    )
    .labelStyle(.displayFieldGenericText)
    .style(.positive)
  }
}
