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

    public var selectedIcon: SwiftUI.Image {
        switch self {
        case .credentials:
            return .ds.item.login.filled
        case .secureNotes:
            return .ds.item.secureNote.filled
        case .payments:
            return .ds.item.payment.filled
        case .personalInfo:
            return .ds.item.personalInfo.filled
        case .ids:
            return .ds.item.id.filled
        }
    }

    public var placeholderIcon: SwiftUI.Image { icon }
}
