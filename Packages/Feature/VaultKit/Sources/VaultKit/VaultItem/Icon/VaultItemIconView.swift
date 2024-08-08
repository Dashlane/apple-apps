import Combine
import CorePersonalData
import IconLibrary
import SwiftUI

public struct VaultItemIconView: View {
  let isListStyle: Bool
  let model: VaultItemIconViewModel

  public init(isListStyle: Bool = true, model: VaultItemIconViewModel) {
    self.isListStyle = isListStyle
    self.model = model
  }

  var sizeType: IconSizeType {
    isListStyle ? .small : .large
  }

  public var body: some View {
    switch model.item.icon(forListStyle: isListStyle) {
    case .credential(let credential):
      DomainIconView(
        model: model.makeDomainIconViewModel(
          credential: credential,
          size: sizeType
        ),
        placeholderTitle: credential.localizedTitle
      )
    case .passkey(let passkey):
      DomainIconView(
        model: model.makeDomainIconViewModel(
          passkey: passkey,
          size: sizeType
        ),
        placeholderTitle: passkey.relyingPartyName,
        accessory: {
          DomainIconAccessoryView(image: .ds.passkey.filled, sizeType: sizeType)
        }
      )
    case .creditCard(let creditCard):
      Image(asset: Asset.imgCard)
        .resizable()
        .foregroundColor(.white)
        .iconStyle(sizeType: sizeType, backgroundColor: creditCard.color.color)
        .modifier(BorderedIcon(sizeType: sizeType))
    case .static(let image, let backgroundColor):
      image
        .resizable()
        .aspectRatio(contentMode: .fit)
        .padding(.vertical, isListStyle ? 6 : 12)
        .iconStyle(sizeType: sizeType, backgroundColor: backgroundColor)
        .modifier(BorderedIcon(sizeType: sizeType))
    }
  }
}

extension VaultItemIconView: Equatable {
  public static func == (lhs: VaultItemIconView, rhs: VaultItemIconView) -> Bool {
    return lhs.model.item.icon(forListStyle: lhs.isListStyle)
      == rhs.model.item.icon(forListStyle: rhs.isListStyle)
  }
}

extension VaultItem {
  func icon(forListStyle isListStyle: Bool) -> VaultItemIcon {
    return isListStyle ? listIcon : icon
  }
}
