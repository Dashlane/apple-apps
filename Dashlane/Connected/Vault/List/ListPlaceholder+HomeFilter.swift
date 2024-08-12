import CoreLocalization
import SwiftUI
import VaultKit

extension ListPlaceholder {
  init(
    vaultListFilter: ItemCategory?, canEditSecureNotes: Bool,
    action: @escaping (VaultItem.Type) -> Void
  ) {
    let buttonText =
      vaultListFilter?.placeholderCtaTitle ?? L10n.Localizable.announceWelcomeM2DNoItemCta
    let addButton = AddVaultButton(
      text: Text(buttonText),
      category: vaultListFilter,
      selectAction: action
    )
    .eraseToAnyView()
    let hideAddButton = vaultListFilter == .secureNotes && !canEditSecureNotes

    if let category = vaultListFilter {
      self.init(
        category: category,
        accessory: hideAddButton ? nil : addButton)
    } else {
      self.init(
        icon: Image(asset: FiberAsset.emptyRecent),
        text: CoreLocalization.L10n.Core.emptyRecentActivityText,
        accessory: addButton)
    }
  }
}
