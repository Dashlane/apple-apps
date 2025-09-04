import CoreLocalization
import CorePersonalData
import DesignSystem
import SwiftUI
import VaultKit

extension ListPlaceholder where Accessory == ListPlaceHolderVaultAccessory {
  init(
    vaultListFilter: ItemCategory?, canAddSecureNotes: Bool,
    action: @escaping (VaultItem.Type) -> Void
  ) {
    let hideAddButton = vaultListFilter == .secureNotes && !canAddSecureNotes

    let accessory = ListPlaceHolderVaultAccessory(
      vaultListFilter: vaultListFilter,
      hideAddButton: hideAddButton,
      action: action)

    if let category = vaultListFilter {
      self.init(category: category) {
        accessory
      }
    } else {
      self.init(
        icon: .ds.item.login.outlined,
        title: CoreL10n.emptyItemsListTitle,
        description: CoreL10n.emptyItemsListDescription
      ) {
        accessory
      }
    }
  }
}

struct ListPlaceHolderVaultAccessory: View {
  let vaultListFilter: ItemCategory?
  let hideAddButton: Bool
  let action: (VaultItem.Type) -> Void

  var body: some View {
    if !hideAddButton {
      AddVaultButton(
        text: Text(vaultListFilter?.placeholderCTATitle ?? CoreL10n.emptyItemsListCTA),
        isImportEnabled: true,
        category: vaultListFilter,
        onAction: { actionCase in
          switch actionCase {
          case .add(let type):
            action(type)
          case .import:
            break
          }
        }
      )
    }
  }
}
