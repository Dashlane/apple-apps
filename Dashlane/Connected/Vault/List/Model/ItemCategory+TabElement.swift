import Foundation
import CorePersonalData
import SwiftUI
import DesignSystem
import VaultKit

extension ItemCategory: TabElement {

    var tabBarImage: NavigationImageSet {
        sidebarImage
    }

    var sidebarImage: NavigationImageSet {
        switch self {
        case .credentials:
            return .init(image: .ds.item.login.outlined,
                         selectedImage: .ds.item.login.filled)
        case .secureNotes:
            return .init(image: .ds.item.secureNote.outlined,
                         selectedImage: .ds.item.secureNote.filled)
        case .payments:
            return .init(image: .ds.item.payment.outlined,
                         selectedImage: .ds.item.payment.filled)
        case .personalInfo:
            return .init(image: .ds.item.personalInfo.outlined,
                         selectedImage: .ds.item.personalInfo.filled)
        case .ids:
            return .init(image: .ds.item.id.outlined,
                         selectedImage: .ds.item.id.filled)
        }
    }
}
