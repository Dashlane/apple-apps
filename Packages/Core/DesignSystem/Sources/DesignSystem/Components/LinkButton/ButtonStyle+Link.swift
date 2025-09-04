import SwiftUI

public struct LinkButtonStyle: ButtonStyle {
  public enum Kind {
    case external
    case `internal`
  }

  @ScaledMetric private var accessoryImageDimension = 16
  @ScaledMetric private var backgroundHorizontalPadding = 8
  @ScaledMetric private var backgroundVerticalPadding = 6
  @ScaledMetric private var backgroundCornerRadius = 10

  var backgroundShape: RoundedRectangle {
    RoundedRectangle(
      cornerRadius: backgroundCornerRadius,
      style: .continuous
    )
  }

  private let kind: Kind

  public init(_ kind: Kind) {
    self.kind = kind
  }

  public func makeBody(configuration: Configuration) -> some View {
    Label(
      title: {
        configuration.label
      },
      icon: {
        accessoryImage
          .resizable()
          .frame(
            width: accessoryImageDimension,
            height: accessoryImageDimension
          )
          .accessibilityHidden(true)
      }
    )
    .labelStyle(.link)
    .background(
      backgroundShape
        .foregroundStyle(.ds.expressiveContainer)
        .padding(.horizontal, -backgroundHorizontalPadding)
        .padding(.vertical, -backgroundVerticalPadding)
    )
    .highlighted(configuration.isPressed)
    .transformEnvironment(\.style) { style in
      style = Style(mood: style.mood, intensity: .supershy, priority: style.priority)
    }
    .accessibilityAddTraits(kind == .external ? .isLink : [])
    .contentShape(.hoverEffect, backgroundShape)
    .hoverEffect()
  }

  private var accessoryImage: Image {
    switch kind {
    case .external:
      return .ds.action.openExternalLink.outlined
    case .internal:
      return .ds.arrowRight.outlined
    }
  }
}

extension ButtonStyle where Self == LinkButtonStyle {
  public static var internalLink: Self {
    LinkButtonStyle(.internal)
  }

  public static var externalLink: Self {
    LinkButtonStyle(.external)
  }
}

struct LinkButtonStyle_Preview: PreviewProvider {
  static var previews: some View {
    VStack(spacing: 16) {
      ForEach(Mood.allCases) { mood in
        VStack(spacing: 16) {
          Button("Hello World") {}
            .buttonStyle(.internalLink)
          Button("Hello World") {}
            .buttonStyle(.externalLink)
            .controlSize(.small)
        }
        .style(mood: mood)
      }
    }
  }
}
