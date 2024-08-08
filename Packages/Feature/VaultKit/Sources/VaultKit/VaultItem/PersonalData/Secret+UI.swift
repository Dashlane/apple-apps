import CoreLocalization
import CorePersonalData
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
      return L10n.Core.Secrets.protectedMessage
    }
    return displaySubtitle ?? ""
  }

  public static var localizedName: String {
    L10n.Core.mainMenuSecrets
  }

  public static var addTitle: String {
    L10n.Core.addASecret
  }

  public static var nativeMenuAddTitle: String {
    return L10n.Core.addSecret
  }
}
