import Foundation
import SwiftUI
import CorePersonalData
import DesignSystem

extension SecureNote {
    
    public var icon: VaultItemIcon {
        .static(.ds.item.secureNote.outlined, backgroundColor: color.color)
    }
    
    public static var addIcon: SwiftUI.Image {
        .ds.item.secureNote.outlined
    }
}
