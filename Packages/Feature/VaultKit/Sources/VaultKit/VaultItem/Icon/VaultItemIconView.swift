import SwiftUI
import CorePersonalData
import Combine
import IconLibrary

public struct VaultItemIconView: View {
    let isListStyle: Bool
    let model: VaultItemIconViewModel

    public init(isListStyle: Bool = true, model: VaultItemIconViewModel) {
        self.isListStyle = isListStyle
        self.model = model
    }

    @ViewBuilder
    public var body: some View {
        switch model.item.icon(forListStyle: isListStyle) {
        case .credential(let credential):
            DomainIconView(
                model: model.makeDomainIconViewModel(
                    credential: credential,
                    size: isListStyle ? .small : .large
                ),
                placeholderTitle: credential.localizedTitle
            )
        case .creditCard(let creditCard):
            Image(asset: Asset.imgCard)
                .resizable()
                .foregroundColor(.white)
                .iconStyle(sizeType: isListStyle ? .small : .large, backgroundColor: creditCard.color.color)
        case .static(let image, let backgroundColor):
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.vertical, isListStyle ? 6 : 12)
                .iconStyle(sizeType: isListStyle ? .small : .large, backgroundColor: backgroundColor)
        }
    }
}

extension VaultItemIconView: Equatable {
    public static func == (lhs: VaultItemIconView, rhs: VaultItemIconView) -> Bool {
        return lhs.model.item.icon(forListStyle: lhs.isListStyle) == rhs.model.item.icon(forListStyle: rhs.isListStyle)
    }
}

extension VaultItem {
    func icon(forListStyle isListStyle: Bool) -> VaultItemIcon {
        return isListStyle ? listIcon : icon
    }
}
