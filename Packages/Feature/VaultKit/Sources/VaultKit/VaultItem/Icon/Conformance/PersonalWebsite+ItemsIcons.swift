import Foundation
import SwiftUI
import CorePersonalData
import DesignSystem

extension PersonalWebsite {
    public var listIcon: VaultItemIcon {
        .static(.ds.web.outlined)
    }
    
    public var icon: VaultItemIcon {
        .static(.ds.web.outlined)
    }
    
    public static var addIcon: SwiftUI.Image {
        .ds.web.outlined
    }
}
