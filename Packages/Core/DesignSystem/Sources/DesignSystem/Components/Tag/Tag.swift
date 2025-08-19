import SwiftUI

public struct Tag: View {
  @Environment(\.highlightedValue) private var highlightedValue

  public enum LeadingAccessory: Equatable {
    case icon(Image)
    case emoji(Character)
  }

  public enum TrailingAccessory: Equatable {
    case icon(Image)
  }

  @ScaledMetric private var contentSpacing = 4
  @ScaledMetric private var verticalPadding = 5
  @ScaledMetric private var horizontalPadding = 8
  @ScaledMetric private var accessoryExtraHorizontalPadding = 4
  @ScaledMetric private var accessoryLessExtraHorizontalPadding = 5

  @ScaledMetric private var leadingIconDimension = 16
  @ScaledMetric private var trailingIconDimension = 12
  @ScaledMetric private var borderWidth = 1
  @ScaledMetric private var cornerRadius = 12

  private let text: String
  private let leadingAccessory: LeadingAccessory?
  private let trailingAccessory: TrailingAccessory?

  public init(
    _ text: String,
    leadingAccessory: LeadingAccessory? = nil,
    trailingAccessory: TrailingAccessory? = nil
  ) {
    self.leadingAccessory = leadingAccessory
    self.trailingAccessory = trailingAccessory
    self.text = text
  }

  public var body: some View {
    HStack(spacing: contentSpacing) {
      leadingAccessoryView
        .accessibilityHidden(true)
      titleView
        .textStyle(.body.standard.regular)
        .foregroundStyle(Color.ds.text.neutral.standard)
        .lineLimit(1)
        .fixedSize(horizontal: true, vertical: false)
      trailingAccessoryView
    }
    .padding(.horizontal, horizontalPadding)
    .padding(.vertical, verticalPadding)
    .padding(extraPadding)
    .background(
      RoundedRectangle(
        cornerRadius: cornerRadius,
        style: .continuous
      )
      .strokeBorder(
        Color.ds.border.neutral.quiet.idle,
        lineWidth: borderWidth
      )
    )
    .accessibilityElement(children: .combine)
  }

  @ViewBuilder
  private var titleView: some View {
    if let attributedString = AttributedString.highlightedValue(highlightedValue, in: text) {
      Text(attributedString)
    } else {
      Text(verbatim: text)
    }
  }

  @ViewBuilder
  private var leadingAccessoryView: some View {
    if let leadingAccessory {
      switch leadingAccessory {
      case .icon(let icon):
        icon
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(
            width: leadingIconDimension,
            height: leadingIconDimension
          )
      case .emoji(let emoji):
        Text(verbatim: String(emoji))
          .textStyle(.body.reduced.regular)
          .fixedSize(
            horizontal: true,
            vertical: true
          )
          .scaleEffect(0.85)
      }
    }
  }

  @ViewBuilder
  private var trailingAccessoryView: some View {
    if let trailingAccessory {
      switch trailingAccessory {
      case .icon(let icon):
        icon
          .resizable()
          .aspectRatio(contentMode: .fit)
          .foregroundStyle(Color.ds.text.neutral.quiet)
          .frame(
            width: trailingIconDimension,
            height: trailingIconDimension
          )
      }
    }
  }

  private var extraPadding: EdgeInsets {
    switch (leadingAccessory, trailingAccessory) {
    case (.some, .some):
      return .init(
        top: 0,
        leading: accessoryExtraHorizontalPadding,
        bottom: 0,
        trailing: accessoryExtraHorizontalPadding
      )
    case (.some, nil):
      return .init(
        top: 0,
        leading: accessoryExtraHorizontalPadding,
        bottom: 0,
        trailing: accessoryExtraHorizontalPadding
      )
    case (nil, .some):
      return .init(
        top: 0,
        leading: accessoryLessExtraHorizontalPadding,
        bottom: 0,
        trailing: accessoryExtraHorizontalPadding
      )
    case (nil, nil):
      return .init(
        top: 0,
        leading: accessoryLessExtraHorizontalPadding,
        bottom: 0,
        trailing: accessoryLessExtraHorizontalPadding
      )
    }
  }
}

struct Tag_Previews: PreviewProvider {

  static private var commonView: some View {
    VStack(spacing: 20) {
      HStack(spacing: 20) {
        VStack(spacing: 20) {
          Tag("Category")
          Tag("Emoji L", leadingAccessory: .emoji("🌚"))
          Tag("Shopping", leadingAccessory: .emoji("🛒"))
          Tag("Shared", leadingAccessory: .icon(.ds.folder.outlined))
          Tag("Magic", trailingAccessory: .icon(.ds.shared.outlined))
            .highlightedValue("agic")
          Tag(
            "Work",
            leadingAccessory: .emoji("💼"),
            trailingAccessory: .icon(.ds.shared.outlined)
          )
        }
        VStack(spacing: 20) {
          Tag("Category")
          Tag("Emoji L", leadingAccessory: .emoji("🌚"))
          Tag("Shopping", leadingAccessory: .emoji("🛒"))
          Tag("Folder", leadingAccessory: .icon(.ds.folder.outlined))
          Tag("Magic", trailingAccessory: .icon(.ds.shared.outlined))
            .highlightedValue("agic")
          Tag(
            "Work",
            leadingAccessory: .emoji("💼"),
            trailingAccessory: .icon(.ds.shared.outlined)
          )
        }
        .dynamicTypeSize(.xxxLarge)
      }
      HStack {
        Tag("Healthcare", leadingAccessory: .emoji("❤️"))
        Tag("Family", leadingAccessory: .emoji("👨‍👩‍👧‍👦"))
        Tag("Travel", leadingAccessory: .emoji("✈️"))
      }
    }
    .padding(60)
    .previewLayout(.sizeThatFits)
  }

  static var previews: some View {
    commonView
      .previewDisplayName("Light")

    commonView
      .preferredColorScheme(.dark)
      .previewDisplayName("Dark")
  }
}
