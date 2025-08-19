import CoreLocalization
import CorePersonalData
import DashlaneAPI
import Foundation

extension WiFi: VaultItem {
  public var enumerated: VaultItemEnumeration {
    return .wifi(self)
  }

  public var localizedTitle: String {
    return displayTitle
  }

  public var localizedSubtitle: String {
    return displaySubtitle ?? ""
  }

  public static var localizedName: String {
    L10n.Core.WiFi.mainMenu
  }

  public static var addTitle: String {
    L10n.Core.WiFi.add
  }

  public static var nativeMenuAddTitle: String {
    L10n.Core.WiFi.add
  }
}
