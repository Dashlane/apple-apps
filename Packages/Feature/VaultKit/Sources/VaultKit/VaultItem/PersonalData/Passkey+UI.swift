import CoreLocalization
import CorePersonalData
import CorePremium
import DashTypes
import Foundation
import SwiftUI

extension Passkey: VaultItem {

  public var enumerated: VaultItemEnumeration {
    .passkey(self)
  }

  public var localizedTitle: String {
    title.isEmpty ? relyingPartyName : title
  }

  public var localizedSubtitle: String {
    userDisplayName
  }

  public static var localizedName: String {
    L10n.Core.Passkey.title
  }

  public static var addTitle: String {
    assertionFailure("Users cannot add passkeys manually")
    return ""
  }

  public static var nativeMenuAddTitle: String {
    assertionFailure("Users cannot add passkeys manually")
    return ""
  }
}
