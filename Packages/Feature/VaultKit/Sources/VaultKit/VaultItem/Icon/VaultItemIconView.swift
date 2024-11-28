import Combine
import CorePersonalData
import DesignSystem
import IconLibrary
import SwiftUI

public struct VaultItemIconView: View {
  let isListStyle: Bool
  let isLarge: Bool
  let model: VaultItemIconViewModel

  public init(isListStyle: Bool = true, isLarge: Bool = false, model: VaultItemIconViewModel) {
    self.isListStyle = isListStyle
    self.isLarge = isLarge
    self.model = model
  }

  public var body: some View {
    switch model.item.icon(forListStyle: isListStyle) {
    case .address:
      DS.Thumbnail.VaultItem.address
        .foregroundStyle(Color(asset: Asset.secureNoteGray))
        .controlSize(isLarge ? .large : .small)
    case .bankAccount:
      DS.Thumbnail.VaultItem.bankAccount
        .foregroundStyle(Color(asset: Asset.secureNoteGray))
        .controlSize(isLarge ? .large : .small)
    case .company:
      DS.Thumbnail.VaultItem.company
        .foregroundStyle(Color(asset: Asset.secureNoteGray))
        .controlSize(isLarge ? .large : .small)
    case .credential(let credential):
      DomainIconView(
        model: model.makeDomainIconViewModel(
          credential: credential
        ),
        isLarge: isLarge
      )
    case .creditCard(let creditCard):
      DS.Thumbnail.VaultItem.paymentCard
        .foregroundStyle(creditCard.color.color)
        .controlSize(isLarge ? .large : .small)
    case .drivingLicense:
      DS.Thumbnail.VaultItem.driversLicense
        .foregroundStyle(Color(asset: Asset.secureNoteGray))
        .controlSize(isLarge ? .large : .small)
    case .email:
      DS.Thumbnail.VaultItem.email
        .foregroundStyle(Color(asset: Asset.secureNoteGray))
        .controlSize(isLarge ? .large : .small)
    case .idCard:
      DS.Thumbnail.VaultItem.idCard
        .foregroundStyle(Color(asset: Asset.secureNoteGray))
        .controlSize(isLarge ? .large : .small)
    case .identity:
      DS.Thumbnail.VaultItem.name
        .foregroundStyle(Color(asset: Asset.secureNoteGray))
        .controlSize(isLarge ? .large : .small)
    case .passkey(let passkey):
      DomainIconView(
        model: model.makeDomainIconViewModel(
          passkey: passkey
        ),
        isLarge: isLarge
      )
    case .passport:
      DS.Thumbnail.VaultItem.passport
        .foregroundStyle(Color(asset: Asset.secureNoteGray))
        .controlSize(isLarge ? .large : .small)
    case .personalWebsite:
      DS.Thumbnail.VaultItem.website
        .foregroundStyle(Color(asset: Asset.secureNoteGray))
        .controlSize(isLarge ? .large : .small)
    case .phoneNumber:
      DS.Thumbnail.VaultItem.phoneNumber
        .foregroundStyle(Color(asset: Asset.secureNoteGray))
        .controlSize(isLarge ? .large : .small)
    case .secret:
      DS.Thumbnail.VaultItem.passkey
        .foregroundStyle(Color(asset: Asset.secureNoteGray))
        .controlSize(isLarge ? .large : .small)
    case .secureNote(let color):
      DS.Thumbnail.VaultItem.secureNote
        .foregroundStyle(color)
        .controlSize(isLarge ? .large : .small)
    case .socialSecurityCard:
      DS.Thumbnail.VaultItem.socialSecurityCard
        .foregroundStyle(Color(asset: Asset.secureNoteGray))
        .controlSize(isLarge ? .large : .small)
    case .static(let image, _):
      image
        .resizable()
        .aspectRatio(contentMode: .fit)
        .padding(.vertical, isListStyle ? 6 : 12)
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
