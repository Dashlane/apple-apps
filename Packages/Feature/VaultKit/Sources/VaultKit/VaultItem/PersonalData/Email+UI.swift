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
      return L10n.Core.kwEmailIOS
    }

    return name
  }

  public var localizedSubtitle: String {
    return value
  }

  public static var localizedName: String {
    L10n.Core.kwEmailIOS
  }

  public static var addTitle: String {
    L10n.Core.kwadddatakwEmailIOS
  }

  public static var nativeMenuAddTitle: String {
    L10n.Core.addEmail
  }

  public func isAssociated(to team: PremiumStatusTeamInfo) -> Bool {
    team.isValueMatchingDomains(self.value)
  }
}

extension Email.EmailType {

  typealias KWEmailIOSTypeL10n = L10n.Core.KWEmailIOS.`Type`

  public var localizedString: String {
    switch self {
    case .personal:
      return KWEmailIOSTypeL10n.perso
    case .work:
      return KWEmailIOSTypeL10n.pro
    }
  }
}
