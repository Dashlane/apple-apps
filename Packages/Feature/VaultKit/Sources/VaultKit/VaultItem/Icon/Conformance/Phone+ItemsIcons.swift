import Foundation
import SwiftUI
import CorePersonalData
import DesignSystem

extension Phone {
    public var listIcon: VaultItemIcon {
        .static(.ds.item.phoneMobile.outlined)
    }

    public var icon: VaultItemIcon {
        .static(.ds.item.phoneMobile.outlined)
    }

    public static var addIcon: SwiftUI.Image {
        .ds.item.phoneMobile.outlined
    }
}
