import CoreLocalization
import SwiftUI

struct FieldActionsStack<Content: View>: View {
  @Environment(\.dynamicTypeSize.isAccessibilitySize) private var isAccessibilitySize

  @ScaledMetric private var horizontalPadding = 4

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
        .buttonStyle(.designSystem(.iconOnly))
        .style(intensity: .supershy)
    }
    .padding(.horizontal, horizontalPadding)
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

    ForEach(children.prefix(prefix)) { child in
      child
    }

    if shouldMakeMenu {
      FieldAction.Menu(
        CoreL10n.moreActionAccessibilityLabel,
        image: .ds.action.more.outlined
      ) {
        ForEach(children.suffix(from: maxItemsNumber - 1)) { child in
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
