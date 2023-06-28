import Foundation
import CorePersonalData
import SwiftUI
import CoreSpotlight
import CoreLocalization

extension Address: VaultItem {

    public var enumerated: VaultItemEnumeration {
        .address(self)
    }

    public var localizedTitle: String {
        name.isEmpty ? L10n.Core.kwAddressIOS : name
    }

    public var localizedSubtitle: String {
        displayAddress
            .components(separatedBy: "\n")
            .joined(separator: ", ")
    }

    public static var localizedName: String {
        L10n.Core.kwAddressIOS
    }

    public static var addTitle: String {
        L10n.Core.kwadddatakwAddressIOS
    }

    public static var nativeMenuAddTitle: String {
        L10n.Core.addAddress
    }
}

extension L10n.Core.KWAddressIOS {
    public static func stateFieldTitle(for variant: StateVariant) -> String {
        switch variant {
        case .county:
            return L10n.Core.KWAddressIOS.county
        case .state:
            return L10n.Core.KWAddressIOS.state
        }
    }

    public static func zipCodeFieldTitle(for variant: StateVariant) -> String {
        switch variant {
        case .county:
            return L10n.Core.KWAddressIOS.postcode
        case .state:
            return L10n.Core.KWAddressIOS.zipCode
        }
    }
}
