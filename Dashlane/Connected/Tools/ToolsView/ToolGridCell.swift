import DesignSystem
import SwiftUI
import UIDelight

struct ToolGridCell: View {

  let tool: ToolInfo

  @Environment(\.sizeCategory) var sizeCategory

  @ScaledMetric
  var imageHeightAndWidth: CGFloat = 30

  private var accessibilityLabel: String {
    if let badgeStatus = tool.badgeStatus {
      return "\(tool.item.title). \(badgeStatus.accessibilityLabel)"
    } else {
      return tool.item.title
    }
  }

  var body: some View {
    cell
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .fiberAccessibilityLabel(.init(accessibilityLabel))
      .accessibilityIdentifier(tool.item.title)
  }

  @ViewBuilder
  var cell: some View {
    VStack(spacing: 16) {
      iconAndTag
      VStack {
        title
        Spacer()
      }
    }
    .fiberAccessibilityHidden(true)
    .accessibilityElement(children: .ignore)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding(12)
    .background(Color.ds.container.agnostic.neutral.supershy)
    .cornerRadius(8)
  }

  @ViewBuilder
  var iconAndTag: some View {
    AdaptiveHStack(verticalAlignment: .top, spacing: 0) {
      tool.item.icon
        .renderingMode(.template)
        .resizable()
        .frame(width: imageHeightAndWidth, height: imageHeightAndWidth)
        .foregroundColor(.ds.text.brand.quiet)
      if !sizeCategory.isAccessibilityCategory {
        Spacer()
      }
      if let status = tool.badgeStatus {
        FeatureBadge(status)
          .style(mood: .brand, intensity: .quiet)

      }
    }
    .frame(minHeight: 35)
  }

  @ViewBuilder
  var title: some View {
    HStack(alignment: .top) {
      Text(tool.item.title)
        .font(.headline.weight(.semibold).leading(.loose))
        .foregroundColor(.ds.text.neutral.catchy)
        .multilineTextAlignment(.leading)
      Spacer()
    }
  }
}

struct ToolsViewCellView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview(dynamicTypePreview: true) {
      VStack(spacing: 10) {
        ToolGridCell(tool: ToolInfo(item: .secureWifi, status: .available(beta: false)))
          .frame(minHeight: 112)
        ToolGridCell(tool: ToolInfo(item: .secureWifi, status: .needsUpgrade))
          .frame(minHeight: 112)
        ToolGridCell(tool: ToolInfo(item: .secureWifi, status: .available(beta: true)))
          .frame(minHeight: 112)
      }
      .backgroundColorIgnoringSafeArea(.red)
      .previewLayout(.sizeThatFits)
    }
  }
}
