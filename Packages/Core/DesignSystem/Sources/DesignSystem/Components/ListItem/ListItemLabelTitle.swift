import Foundation
import SwiftUI

public struct ListItemLabelTitle<Icons: View>: View {
  @Environment(\.highlightedValue) private var highlightedValue

  private let badgeText: String?
  private let icons: Icons
  private let title: String

  public init(
    _ title: String,
    badge: String? = nil,
    @ViewBuilder icons: () -> Icons
  ) {
    self.badgeText = badge
    self.icons = icons()
    self.title = title
  }

  public init(
    _ title: String,
    badge: String? = nil
  ) where Icons == EmptyView {
    self.badgeText = badge
    self.icons = EmptyView()
    self.title = title
  }

  public var body: some View {
    HStack(spacing: 4) {
      titleView
        .textStyle(.body.standard.regular)
        .foregroundStyle(Color.ds.text.neutral.standard)

      _VariadicView.Tree(IconsStackRoot()) {
        icons
      }

      if let badgeText {
        DS.Badge(badgeText)
          .style(mood: .neutral, intensity: .quiet)
      }
    }
  }

  @ViewBuilder
  private var titleView: some View {
    if let attributedTitle = AttributedString.highlightedValue(highlightedValue, in: title) {
      Text(attributedTitle)
    } else {
      Text(title)
    }
  }
}

private struct IconsStackRoot: _VariadicView.MultiViewRoot {
  @ScaledMetric private var iconHeight = 12

  func body(children: _VariadicView.Children) -> some View {
    ForEach(children) { child in
      child
        .aspectRatio(contentMode: .fit)
        .frame(height: iconHeight)
        .foregroundStyle(Color.ds.text.neutral.quiet)
    }
  }
}

#Preview("w/o badge") {
  ListItemLabelTitle("Title")
    .highlightedValue("itl")
}

#Preview("w/ badge") {
  ListItemLabelTitle("Title", badge: "New")
    .highlightedValue("itl")
}

#Preview("w/ icons") {
  ListItemLabelTitle("Title") {
    Image.ds.arrowDown.outlined
      .resizable()
    Image.ds.arrowUp.outlined
      .resizable()
  }
  .highlightedValue("itl")
}

#Preview("w/ badge & icons") {
  ListItemLabelTitle("Title", badge: "New") {
    Image.ds.arrowDown.outlined
      .resizable()
    Image.ds.arrowUp.outlined
      .resizable()
  }
  .highlightedValue("itl")
}
