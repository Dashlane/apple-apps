import CoreLocalization
import CorePersonalData
import CorePremium
import CoreTypes
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
    CoreL10n.KWAuthentifiantIOS.password
  }

  public static var addTitle: String {
    CoreL10n.kwadddatakwAuthentifiantIOS
  }

  public static var nativeMenuAddTitle: String {
    CoreL10n.addPassword
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
