import Foundation
import SwiftUI
import CorePersonalData
import DesignSystem

extension CreditCard {
    
    public var icon: VaultItemIcon {
        .creditCard(self)
    }
    
    public static var addIcon: SwiftUI.Image {
        .ds.item.payment.outlined
    }
    
}
