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
    Group {
      switch model.item.icon {
      case .address:
        DS.Thumbnail.VaultItem.address
          .foregroundStyle(Color.ds.defaultVaultColor)
      case .bankAccount:
        DS.Thumbnail.VaultItem.bankAccount
          .foregroundStyle(Color.ds.defaultVaultColor)
      case .company:
        DS.Thumbnail.VaultItem.company
          .foregroundStyle(Color.ds.defaultVaultColor)
      case .credential(let credential):
        DomainIconView(model: model.makeDomainIconViewModel(credential: credential))
      case .creditCard(let creditCard):
        DS.Thumbnail.VaultItem.paymentCard
          .foregroundStyle(creditCard.color.color)
      case .drivingLicense:
        DS.Thumbnail.VaultItem.driversLicense
          .foregroundStyle(Color.ds.defaultVaultColor)
      case .email:
        DS.Thumbnail.VaultItem.email
          .foregroundStyle(Color.ds.defaultVaultColor)
      case .idCard:
        DS.Thumbnail.VaultItem.idCard
          .foregroundStyle(Color.ds.defaultVaultColor)
      case .identity:
        DS.Thumbnail.VaultItem.name
          .foregroundStyle(Color.ds.defaultVaultColor)
      case .passkey(let passkey):
        DomainIconView(model: model.makeDomainIconViewModel(passkey: passkey))
      case .passport:
        DS.Thumbnail.VaultItem.passport
          .foregroundStyle(Color.ds.defaultVaultColor)
      case .personalWebsite:
        DS.Thumbnail.VaultItem.website
          .foregroundStyle(Color.ds.defaultVaultColor)
      case .phoneNumber:
        DS.Thumbnail.VaultItem.phoneNumber
          .foregroundStyle(Color.ds.defaultVaultColor)
      case .secret:
        DS.Thumbnail.VaultItem.passkey
          .foregroundStyle(Color.ds.defaultVaultColor)
      case .secureNote(let color):
        DS.Thumbnail.VaultItem.secureNote
          .foregroundStyle(color)
      case .socialSecurityCard:
        DS.Thumbnail.VaultItem.socialSecurityCard
          .foregroundStyle(Color.ds.defaultVaultColor)
      case .fiscalInformation:
        DS.Thumbnail.VaultItem.fiscalInformation
          .foregroundStyle(Color.ds.defaultVaultColor)
      case .wifi:
        DS.Thumbnail.VaultItem.wifi
          .foregroundStyle(Color.ds.defaultVaultColor)
      case .static(let image, _):
        image
          .resizable()
          .aspectRatio(contentMode: .fit)
          .padding(.vertical, isListStyle ? 6 : 12)
      }
    }
    .controlSize(isLarge ? .large : .regular)
  }
}

extension Color.ds {
  fileprivate static let defaultVaultColor: Color = .ds.container.decorative.grey
}

extension VaultItemIconView: Equatable {
  public static func == (lhs: VaultItemIconView, rhs: VaultItemIconView) -> Bool {
    return lhs.model.item.icon == rhs.model.item.icon
  }
}
