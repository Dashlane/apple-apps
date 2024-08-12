import CorePersonalData
import Foundation
import VaultKit

extension VaultFlowViewModel {
  func showAddItemMenuView(displayMode: AddItemFlowViewModel.DisplayMode) {
    guard vaultItemsLimitService.canAddNewItem(for: displayMode) else {
      deepLinkingService.handleLink(
        .premium(.planPurchase(initialView: .paywall(trigger: .capability(key: .passwordsLimit)))))
      return
    }

    addItemFlowDisplayMode = displayMode
    showAddItemFlow = true
  }
}

extension VaultItemsLimitServiceProtocol {
  func canAddNewItem(for displayMode: AddItemFlowViewModel.DisplayMode) -> Bool {
    switch displayMode {
    case .itemType(let itemType):
      return canAddNewItem(for: itemType)
    case .categoryDetail(let category):
      return canAddNewItem(for: category)
    case .prefilledPassword:
      return canAddNewItem(for: Credential.self)
    }
  }
}
