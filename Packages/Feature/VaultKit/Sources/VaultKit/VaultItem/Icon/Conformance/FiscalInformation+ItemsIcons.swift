import Foundation
import SwiftUI
import CorePersonalData
import DesignSystem

extension FiscalInformation {
    public var listIcon: VaultItemIcon {
        .static(.ds.item.bankAccount.outlined)
    }
    
    public var icon: VaultItemIcon {
        .static(.ds.item.bankAccount.outlined)
    }
    
    public static var addIcon: SwiftUI.Image {
        .ds.item.bankAccount.outlined
    }
}
