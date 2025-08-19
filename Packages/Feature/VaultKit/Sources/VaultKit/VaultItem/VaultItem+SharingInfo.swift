import CorePersonalData
import Foundation

extension VaultItem {

  public var canEditItem: Bool {
    switch self.vaultItemType {
    case .credential:
      true
    case .secureNote:
      metadata.sharingPermission != .limited
    default:
      true
    }
  }
}
