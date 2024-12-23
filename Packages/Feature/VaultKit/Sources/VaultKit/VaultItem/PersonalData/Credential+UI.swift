import CoreLocalization
import CorePersonalData
import CorePremium
import DashTypes
import DashlaneAPI
import Foundation
import SwiftUI

extension Credential: VaultItem {
  public var enumerated: VaultItemEnumeration {
    .credential(self)
  }

  public var localizedTitle: String {
    displayTitle
  }

  public var localizedSubtitle: String {
    displaySubtitle ?? ""
  }

  public static var localizedName: String {
    L10n.Core.KWAuthentifiantIOS.password
  }

  public static var addTitle: String {
    L10n.Core.kwadddatakwAuthentifiantIOS
  }

  public static var nativeMenuAddTitle: String {
    L10n.Core.addPassword
  }

  public func isAssociated(to team: PremiumStatusTeamInfo) -> Bool {
    let properties =
      [
        self.login,
        self.email,
        self.url?.rawValue ?? "",
        self.secondaryLogin,
      ]
      + self.linkedServices.associatedDomains.map { $0.domain }

    return properties.contains {
      team.isValueMatchingDomains($0)
    }
  }
}

extension Credential: CopiablePersonalData {
  public var fieldToCopy: DetailFieldType {
    return .password
  }

  public var valueToCopy: String {
    return password
  }
}

extension Credential: TransferablePersonalData {}
