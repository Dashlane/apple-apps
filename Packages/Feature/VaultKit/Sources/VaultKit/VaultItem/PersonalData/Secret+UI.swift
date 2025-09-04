import CoreLocalization
import CorePersonalData
import DashlaneAPI
import Foundation

extension Secret: VaultItem, SecureItem {
  public var enumerated: VaultItemEnumeration {
    return .secret(self)
  }

  public var localizedTitle: String {
    return displayTitle
  }

  public var localizedSubtitle: String {
    guard !secured else {
      return CoreL10n.Secrets.protectedMessage
    }
    return displaySubtitle ?? ""
  }

  public static var localizedName: String {
    CoreL10n.mainMenuSecrets
  }

  public static var addTitle: String {
    CoreL10n.addASecret
  }

  public static var nativeMenuAddTitle: String {
    return CoreL10n.addSecret
  }

  public func isAssociated(to: PremiumStatusTeamInfo) -> Bool {
    return true
  }
}
