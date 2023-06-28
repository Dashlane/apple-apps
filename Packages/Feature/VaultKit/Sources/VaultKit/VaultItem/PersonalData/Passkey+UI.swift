import Foundation

import DashTypes
import CorePersonalData
import SwiftUI
import CoreLocalization
import CorePremium

extension Passkey: VaultItem {

    public var enumerated: VaultItemEnumeration {
        .passkey(self)
    }

    public var localizedTitle: String {
        relyingPartyName
    }

    public var localizedSubtitle: String {
        L10n.Core.Passkey.title
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
