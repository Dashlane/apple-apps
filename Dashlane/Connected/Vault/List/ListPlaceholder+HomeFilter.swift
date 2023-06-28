import SwiftUI
import DashlaneAppKit
import VaultKit
import CoreLocalization

extension ListPlaceholder {
    init(vaultListFilter: VaultItemsSection, canEditSecureNotes: Bool, action: @escaping (VaultItem.Type) -> Void) {
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
                      text: CoreLocalization.L10n.Core.emptyRecentActivityText,
                      accessory: addButton)
        }
    }
}
