import AutofillKit
import Combine
import CoreFeature
import CorePersonalData
import CorePremium
import CoreSettings
import CoreUserTracking
import DashTypes
import ImportKit
import NotificationKit
import SwiftTreats
import SwiftUI
import VaultKit

@MainActor
class HomeViewModel: ObservableObject, SessionServicesInjecting {

  let homeListViewModel: HomeListViewModel
  let searchViewModelFactory: VaultSearchViewModel.Factory
  private let completion: (VaultListCompletion) -> Void
  private let action: (VaultFlowViewModel.Action) -> Void
  private let onboardingAction: (OnboardingChecklistFlowViewModel.Action) -> Void

  init(
    onboardingAction: @escaping (OnboardingChecklistFlowViewModel.Action) -> Void,
    action: @escaping (VaultFlowViewModel.Action) -> Void,
    homeListViewModelFactory: HomeListViewModel.Factory,
    searchFactory: VaultSearchViewModel.Factory
  ) {
    self.action = action

    self.onboardingAction = onboardingAction
    self.completion = { completion in
      switch completion {
      case let .enterDetail(item, selectVaultItem, isEditing):
        action(.didSelectItem(item, selectVaultItem: selectVaultItem, isEditing: isEditing))
      case let .addItem(mode):
        action(.addItem(displayMode: mode))
      }
    }
    homeListViewModel = homeListViewModelFactory.make(
      onboardingAction: onboardingAction,
      action: action,
      completion: completion)
    self.searchViewModelFactory = searchFactory
  }

  func makeSearchViewModel() -> VaultSearchViewModel {
    searchViewModelFactory.make(
      searchCategory: nil,
      completion: completion
    )
  }
}

extension HomeViewModel {
  static var mock: HomeViewModel {
    HomeViewModel(
      onboardingAction: { _ in },
      action: { _ in },
      homeListViewModelFactory: .init { _, _, _ in .mock },
      searchFactory: .init { _, _, _ in .mock }
    )
  }
}
