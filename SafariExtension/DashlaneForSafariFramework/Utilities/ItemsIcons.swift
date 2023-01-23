import Foundation
import SwiftUI
import CorePersonalData
import DashlaneAppKit
import VaultKit

extension VaultItem {
    
    public var icon: VaultItemIcon {
        .static(Image(asset: Asset.emptyImage), backgroundColor: nil)
    }
    
    public static var addIcon: SwiftUI.Image {
        Image(asset: Asset.emptyImage)
    }
}

extension Credential {
    
    public var icon: VaultItemIcon {
        .credential(self)
    }
}
