import Foundation
import SwiftUI
import CorePersonalData
import DesignSystem

extension Email {
    public var icon: VaultItemIcon {
        .static(.ds.item.email.outlined)
    }

    public var listIcon: VaultItemIcon {
        .static(.ds.item.email.outlined)
    }

    public static var addIcon: SwiftUI.Image {
        .ds.item.email.outlined
    }
}
