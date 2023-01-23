import SwiftUI
import DashlaneAppKit
import VaultKit

extension ListPlaceholder {
    init(vaultListFilter: VaultListFilter, canEditSecureNotes: Bool, action: @escaping (VaultItem.Type) -> Void) {
        let buttonText = vaultListFilter.category?.placeholderCtaTitle ?? L10n.Localizable.announceWelcomeM2DNoItemCta
        let addButton =  AddVaultButton(text: Text(buttonText),
                                        secureNoteState: .enabled,
                                        category: vaultListFilter.category,
                                        selectAction: action)
            .eraseToAnyView()
        let hideAddButton = vaultListFilter == .secureNotes && !canEditSecureNotes

        if let category = vaultListFilter.category {
            self.init(category: category,
                      accessory: hideAddButton ? nil : addButton)
        } else {
            self.init(icon: Image(asset: FiberAsset.emptyRecent),
                      text: L10n.Localizable.emptyRecentActivityText,
                      accessory: addButton)
        }
    }
}

extension VaultListFilter {
    var category: ItemCategory? {
        switch self {
        case .credentials:
            return .credentials
        case .secureNotes:
            return .secureNotes
        case .payments:
            return .payments
        case .personalInfo:
            return .personalInfo
        case .ids:
            return .ids
        case .all:
            return nil
        }
    }
}
