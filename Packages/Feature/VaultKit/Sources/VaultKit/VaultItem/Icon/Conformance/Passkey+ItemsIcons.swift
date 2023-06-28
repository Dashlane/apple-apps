import Foundation
import CorePersonalData
import SwiftUI

extension Passkey {

    public static var addIcon: Image {
        assertionFailure("Users cannot add passkeys manually")
        return .ds.passkey.outlined
    }

    public var icon: VaultItemIcon {
        .static(.ds.passkey.outlined,
                backgroundColor: .ds.container.expressive.neutral.catchy.active)
    }
}
