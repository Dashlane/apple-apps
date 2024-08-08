import CoreLocalization
import SwiftUI

struct FieldActionsStack<Content: View>: View {
  @Environment(\.dynamicTypeSize.isAccessibilitySize) private var isAccessibilitySize

  private let allowOverflowStacking: Bool
  private let content: Content
  private let maxItemsNumber: Int

  init(
    maxItemsNumber: Int = 3,
    allowOverflowStacking: Bool = true,
    @ViewBuilder content: () -> Content
  ) {
    self.allowOverflowStacking = allowOverflowStacking
    self.content = content()
    self.maxItemsNumber = maxItemsNumber
  }

  var body: some View {
    HStack(spacing: 0) {
      contentContainer
        .buttonStyle(ActionButtonStyle())
        .menuStyle(ActionMenuStyle())
    }
    .transition(.scale(scale: 0.5).combined(with: .opacity))
  }

  private var contentContainer: some View {
    _VariadicView.Tree(
      FieldActionStackLayout(
        maxItemsNumber: isAccessibilitySize ? min(maxItemsNumber, 2) : maxItemsNumber,
        allowOverflowStacking: allowOverflowStacking
      )
    ) {
      content
    }
  }
}

private struct ActionButtonStyle: ButtonStyle {
  @ScaledMetric private var backgroundCornerRadius = 10
  @ScaledMetric private var imageDimension = 20
  @ScaledMetric private var minimumTapAreaDimension = 40

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .labelStyle(.iconOnly)
      .frame(width: imageDimension, height: imageDimension)
      .frame(minWidth: minimumTapAreaDimension, minHeight: minimumTapAreaDimension)
      .background(
        RoundedRectangle(cornerRadius: backgroundCornerRadius, style: .continuous)
          ._foregroundStyle(.expressiveContainer)
      )
      .contentShape(Rectangle())
      .foregroundStyle(.tint)
      .highlighted(configuration.isPressed)
      .transformEnvironment(\.style) { style in
        style = Style(mood: style.mood, intensity: .supershy, priority: style.priority)
      }
  }
}

private struct ActionMenuStyle: MenuStyle {
  @ScaledMetric private var backgroundCornerRadius = 10
  @ScaledMetric private var imageDimension = 20
  @ScaledMetric private var minimumTapAreaDimension = 40

  func makeBody(configuration: Configuration) -> some View {
    Menu(configuration)
      .labelStyle(.iconOnly)
      .frame(width: imageDimension, height: imageDimension)
      .frame(minWidth: minimumTapAreaDimension, minHeight: minimumTapAreaDimension)
      .background(
        RoundedRectangle(cornerRadius: backgroundCornerRadius, style: .continuous)
          ._foregroundStyle(.expressiveContainer)
      )
      .contentShape(Rectangle())
      .foregroundStyle(.tint)
      .transformEnvironment(\.style) { style in
        style = Style(mood: style.mood, intensity: .supershy, priority: style.priority)
      }
  }
}

private struct FieldActionStackLayout: _VariadicView.MultiViewRoot {
  private let allowOverflowStacking: Bool
  private let maxItemsNumber: Int

  init(maxItemsNumber: Int, allowOverflowStacking: Bool) {
    self.allowOverflowStacking = allowOverflowStacking
    self.maxItemsNumber = maxItemsNumber
  }

  @ViewBuilder
  func body(children: _VariadicView.Children) -> some View {
    let shouldMakeMenu = allowOverflowStacking && (children.count > maxItemsNumber)
    let prefix = shouldMakeMenu ? maxItemsNumber - 1 : maxItemsNumber

    ForEach(children.prefix(prefix).reversed()) { child in
      child
    }

    if shouldMakeMenu {
      FieldAction.Menu(
        L10n.Core.moreActionAccessibilityLabel,
        image: .ds.action.more.outlined
      ) {
        ForEach(children.suffix(from: maxItemsNumber - 1).reversed()) { child in
          child
        }
      }
    }
  }
}

#Preview("Regular") {
  FieldActionsStack {
    DS.FieldAction.Button(
      "Trailing Button",
      image: .ds.caretRight.outlined,
      action: {}
    )
    DS.FieldAction.Button(
      "Center Button",
      image: .ds.menu.outlined,
      action: {}
    )
    DS.FieldAction.Button(
      "Leading Button",
      image: .ds.caretLeft.outlined,
      action: {}
    )
  }
}

#Preview("Overflowing enabled") {
  FieldActionsStack {
    DS.FieldAction.CopyContent {
      print("Copy action.")
    }
    DS.FieldAction.Button(
      "Open External Link",
      image: .ds.action.openExternalLink.outlined,
      action: {}
    )
    DS.FieldAction.Button(
      "Should be inside a menu",
      image: .ds.activityLog.outlined,
      action: {}
    )
    DS.FieldAction.Button(
      "Should also be inside a menu",
      image: .ds.dashboard.outlined,
      action: {}
    )
  }
}

#Preview("Overflowing disabled") {
  FieldActionsStack(maxItemsNumber: 2, allowOverflowStacking: false) {
    DS.FieldAction.CopyContent {
      print("Copy action.")
    }
    DS.FieldAction.Button(
      "Open External Link",
      image: .ds.action.openExternalLink.outlined,
      action: {}
    )
    DS.FieldAction.Button(
      "Should be completely stripped out",
      image: .ds.activityLog.outlined,
      action: {}
    )
    DS.FieldAction.Button(
      "Should be completely stripped out",
      image: .ds.dashboard.outlined,
      action: {}
    )
  }
}
