import Foundation
import SwiftUI
import CorePersonalData
import DesignSystem

extension Identity {
    public var icon: VaultItemIcon {
        .static(.ds.item.personalInfo.outlined)
    }
    
    public var listIcon: VaultItemIcon {
        .static(.ds.item.personalInfo.outlined)
    }
    
    public static var addIcon: SwiftUI.Image {
        .ds.item.personalInfo.outlined
    }
}
