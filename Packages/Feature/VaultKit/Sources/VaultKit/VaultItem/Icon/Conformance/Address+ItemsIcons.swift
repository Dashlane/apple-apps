import Foundation
import SwiftUI
import CorePersonalData
import DesignSystem

extension Address {
    public var listIcon: VaultItemIcon {
        .static(.ds.home.outlined)
    }

    public var icon: VaultItemIcon {
        .static(.ds.home.outlined)
    }

    public static var addIcon: SwiftUI.Image {
        Image(asset: Asset.imgAddress)
    }

}
