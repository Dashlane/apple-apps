import CorePersonalData
import CoreSharing
import CoreTypes
import Foundation
import VaultKit

struct SharedVaultItemInfo<Recipient: SharingGroupMember>: Identifiable {
  let vaultItem: VaultItem
  let group: ItemGroupInfo
  let recipient: Recipient

  var id: Identifier {
    return vaultItem.id
  }
}

extension SharedVaultItemInfo {
  var localizedStatus: String {
    recipient.localizedStatus
  }
}

extension SharingGroupMember {
  var localizedStatus: String {
    if status == .pending {
      return L10n.Localizable.kwUserPending
    }
    return permission.localizedDescription
  }
}

extension SharingPermission {
  var localizedDescription: String {
    switch self {
    case .admin:
      return L10n.Localizable.kwUserFullRights
    case .limited:
      return L10n.Localizable.kwUserLimitedRights
    }
  }
}
