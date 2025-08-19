import CoreLocalization
import CorePersonalData
import CorePremium
import DashlaneAPI
import SwiftUI

extension Email: VaultItem {

  public var enumerated: VaultItemEnumeration {
    return .email(self)
  }

  public var localizedTitle: String {
    guard !name.isEmpty else {
      return CoreL10n.kwEmailIOS
    }

    return name
  }

  public var localizedSubtitle: String {
    return value
  }

  public static var localizedName: String {
    CoreL10n.kwEmailIOS
  }

  public static var addTitle: String {
    CoreL10n.kwadddatakwEmailIOS
  }

  public static var nativeMenuAddTitle: String {
    CoreL10n.addEmail
  }

  public func isAssociated(to team: PremiumStatusTeamInfo) -> Bool {
    team.isValueMatchingDomains(self.value)
  }
}

extension Email.EmailType {

  typealias KWEmailIOSTypeL10n = CoreL10n.KWEmailIOS.`Type`

  public var localizedString: String {
    switch self {
    case .personal:
      return KWEmailIOSTypeL10n.perso
    case .work:
      return KWEmailIOSTypeL10n.pro
    }
  }
}
