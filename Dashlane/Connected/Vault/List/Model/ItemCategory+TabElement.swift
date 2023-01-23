import Foundation
import CorePersonalData
import SwiftUI
import DashlaneAppKit

extension ItemCategory: TabElement {

    var tabBarImage: NavigationImageSet {
        .init(image: image,
              selectedImage: image)
    }

    var image: ImageAsset {
        switch self {
            case .credentials:
                return FiberAsset.menuIconPasswords
            case .secureNotes:
                return FiberAsset.menuIconNotes
            case .payments:
                return FiberAsset.menuIconPaymentmeans
            case .personalInfo:
                return FiberAsset.menuIconPersonalinfos
            case .ids:
                return FiberAsset.menuIconConfidentialcards
        }
    }

    var sidebarImage: NavigationImageSet {
        switch self {
            case .credentials:
                return .init(image: FiberAsset.sidebarVaultCredentials,
                             selectedImage: FiberAsset.sidebarVaultCredentialsSelected)
            case .secureNotes:
                return .init(image: FiberAsset.sidebarVaultNotes,
                             selectedImage: FiberAsset.sidebarVaultNotesSelected)
            case .payments:
                return .init(image: FiberAsset.sidebarVaultPayments,
                             selectedImage: FiberAsset.sidebarVaultPaymentsSelected)
            case .personalInfo:
                return .init(image: FiberAsset.sidebarVaultPersonalinfo,
                             selectedImage: FiberAsset.sidebarVaultPersonalinfoSelected)
            case .ids:
                return .init(image: FiberAsset.sidebarVaultIds,
                             selectedImage: FiberAsset.sidebarVaultIdsSelected)
        }
    }
}
