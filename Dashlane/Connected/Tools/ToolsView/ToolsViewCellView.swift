import SwiftUI
import UIDelight
import DesignSystem

struct ToolsViewCellView: View {

    let cellData: ToolsViewCellData

    @Environment(\.sizeCategory) var sizeCategory

    @ScaledMetric
    var imageHeightAndWidth: CGFloat = 30

    @State
    private var badgeConfiguration: BadgeConfiguration?

    private var accessibilityLabel: String {
        if let badgeConfiguration = badgeConfiguration {
            return "\(cellData.title). \(badgeConfiguration.accessibilityLabel)"
        } else {
            return cellData.title
        }
    }

    var body: some View {
        cell
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .fiberAccessibilityLabel(.init(accessibilityLabel))
            .accessibilityIdentifier(cellData.title)
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
        .background(Color(asset: FiberAsset.cellBackground))
        .cornerRadius(8)
        .onReceive(cellData.badgeConfiguration) { badgeConfiguration in
            self.badgeConfiguration = badgeConfiguration
        }
    }

    @ViewBuilder
    var iconAndTag: some View {
        AdaptiveHStack(verticalAlignment: .top, spacing: 0) {
            cellData.image.swiftUIImage
                .renderingMode(.template)
                .resizable()
                .frame(width: imageHeightAndWidth, height: imageHeightAndWidth)
                .foregroundColor(Color(asset: FiberAsset.accentColor))
            if !sizeCategory.isAccessibilityCategory {
                Spacer()
            }
            if let badgeConfiguration = badgeConfiguration {
                Badge(badgeConfiguration.title)
                    .style(mood: badgeConfiguration.mood, intensity: badgeConfiguration.intensity)
                    .accessibility(label: Text(badgeConfiguration.title))
            }
        }
        .frame(minHeight: 35)
    }

    @ViewBuilder
    var title: some View {
        HStack(alignment: .top) {
            Text(cellData.title)
                .font(.headline.weight(.semibold).leading(.loose))
                .foregroundColor(Color(asset: FiberAsset.mainCopy))
                .multilineTextAlignment(.leading)
            Spacer()
        }
    }
}

struct ToolsViewCellView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview(dynamicTypePreview: true) {
            VStack(spacing: 10) {
                ToolsViewCellView(cellData: .mock(item: .secureWifi, isEnabled: false))
                    .frame(minHeight: 112)
                ToolsViewCellView(cellData: .mock(item: .secureWifi, isEnabled: false))
                    .frame(minHeight: 112)
                ToolsViewCellView(cellData: .mock(item: .secureWifi, isEnabled: false, badgeConfiguration: .upgrade))
                    .frame(minHeight: 112)
            }
            .backgroundColorIgnoringSafeArea(.red)
            .previewLayout(.sizeThatFits)
        }
    }
}
