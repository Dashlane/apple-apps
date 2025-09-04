import CoreLocalization
import CorePersonalData
import CoreSpotlight
import Foundation
import SwiftUI

extension Address: VaultItem {

  public var enumerated: VaultItemEnumeration {
    .address(self)
  }

  public var localizedTitle: String {
    name.isEmpty ? CoreL10n.kwAddressIOS : name
  }

  public var localizedSubtitle: String {
    displayAddress
      .components(separatedBy: "\n")
      .joined(separator: ", ")
  }

  public static var localizedName: String {
    CoreL10n.kwAddressIOS
  }

  public static var addTitle: String {
    CoreL10n.kwadddatakwAddressIOS
  }

  public static var nativeMenuAddTitle: String {
    CoreL10n.addAddress
  }
}

extension CoreL10n.KWAddressIOS {
  public static func stateFieldTitle(for variant: StateVariant) -> String {
    switch variant {
    case .county:
      return CoreL10n.KWAddressIOS.county
    case .state:
      return CoreL10n.KWAddressIOS.state
    }
  }

  public static func zipCodeFieldTitle(for variant: StateVariant) -> String {
    switch variant {
    case .county:
      return CoreL10n.KWAddressIOS.postcode
    case .state:
      return CoreL10n.KWAddressIOS.zipCode
    }
  }
}
