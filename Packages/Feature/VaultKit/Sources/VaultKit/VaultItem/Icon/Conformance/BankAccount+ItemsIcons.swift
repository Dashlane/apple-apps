import Foundation
import SwiftUI
import CorePersonalData
import DesignSystem

extension BankAccount {
    public var icon: VaultItemIcon {
        .static(Image(asset: Asset.bankAccountThumb),
                backgroundColor: Color.clear)
    }

    public static var addIcon: SwiftUI.Image {
        .ds.item.taxNumber.outlined
    }
}
