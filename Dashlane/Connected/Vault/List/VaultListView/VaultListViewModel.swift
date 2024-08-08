import AutofillKit
import Combine
import CoreData
import CoreFeature
import CorePersonalData
import CorePremium
import CoreSettings
import CoreSharing
import CoreUserTracking
import DashTypes
import Foundation
import ImportKit
import NotificationKit
import SwiftTreats
import SwiftUI
import VaultKit

struct VaultSelection {
  let item: VaultItem
  let origin: VaultSelectionOrigin
  let count: Int
}

@MainActor
class VaultListViewModel: ObservableObject, SessionServicesInjecting {
  let activeFilter: ItemCategory?
  private let vaultItemsListFactory: VaultItemsListViewModel.Factory
  private let searchFactory: VaultSearchViewModel.Factory
  private let action: (VaultFlowViewModel.Action) -> Void
  private let onboardingAction: (OnboardingChecklistFlowViewModel.Action) -> Void
  private let completion: (VaultListCompletion) -> Void

  let itemsListViewModel: VaultItemsListViewModel

  init(
    activeFilter: ItemCategory?,
    onboardingAction: @escaping (OnboardingChecklistFlowViewModel.Action) -> Void,
    vaultItemsListFactory: VaultItemsListViewModel.Factory,
    searchFactory: VaultSearchViewModel.Factory,
    action: @escaping (VaultFlowViewModel.Action) -> Void,
    completion: @escaping (VaultListCompletion) -> Void
  ) {
    self.onboardingAction = onboardingAction
    self.action = action
    self.vaultItemsListFactory = vaultItemsListFactory
    self.searchFactory = searchFactory
    self.completion = completion
    self.activeFilter = activeFilter

    itemsListViewModel = vaultItemsListFactory.make(
      activeFilter: activeFilter,
      activeFilterPublisher: Just(activeFilter).eraseToAnyPublisher(),
      completion: completion
    )
  }

  func makeSearchViewModel() -> VaultSearchViewModel {
    searchFactory.make(
      searchCategory: activeFilter,
      completion: completion
    )
  }
}

extension VaultListViewModel {
  static var mock: VaultListViewModel {
    .init(
      activeFilter: nil,
      onboardingAction: { _ in },
      vaultItemsListFactory: .init { _, _, _ in .mock },
      searchFactory: .init { _, _, _ in .mock },
      action: { _ in },
      completion: { _ in }
    )
  }
}
