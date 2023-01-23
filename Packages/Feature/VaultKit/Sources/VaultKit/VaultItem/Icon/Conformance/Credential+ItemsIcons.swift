import Foundation
import SwiftUI
import CorePersonalData
import DesignSystem

extension Credential {
    
    public var icon: VaultItemIcon {
        .credential(self)
    }
    
    public static var addIcon: SwiftUI.Image {
        .ds.item.login.outlined
    }
    
}
