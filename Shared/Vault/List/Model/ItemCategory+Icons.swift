import DesignSystem
import Foundation
import SwiftUI

extension ItemCategory {
    public var icon: SwiftUI.Image {
        switch self {
        case .credentials:
            return .ds.item.login.outlined
        case .secureNotes:
            return .ds.item.secureNote.outlined
        case .payments:
            return .ds.item.payment.outlined
        case .personalInfo:
            return .ds.item.personalInfo.outlined
        case .ids:
            return .ds.item.id.outlined
        }
    }
    
    public var placeholderIcon: SwiftUI.Image {
        switch self {
        case .credentials:
            return Image(asset: FiberAsset.emptyPasswords)
        case .secureNotes:
            return Image(asset: FiberAsset.emptyNotes)
        case .payments:
            return Image(asset: FiberAsset.emptyPayments)
        case .personalInfo:
            return Image(asset: FiberAsset.emptyPersonalInfo)
        case .ids:
            return Image(asset: FiberAsset.emptyConfidentialCards)
        }
    }
}
