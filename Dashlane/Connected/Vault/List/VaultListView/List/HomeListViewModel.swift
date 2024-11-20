import AutofillKit
import Combine
import CoreFeature
import CorePremium
import CoreSettings
import CoreUserTracking
import Foundation
import ImportKit
import NotificationKit
import VaultKit

@MainActor
class HomeListViewModel: ObservableObject, SessionServicesInjecting {

  private let homeBottomBannerFactory: HomeBottomBannerViewModel.Factory
  private let homeTopBannerFactory: HomeTopBannerViewModel.Factory
  private let vaultItemsListFactory: VaultItemsListViewModel.Factory
  private let action: (VaultFlowViewModel.Action) -> Void
  private let vaultItemsStore: VaultItemsStore
  private let userSettings: UserSettings
  private let isLastpassInstalled: Bool
  let sessionActivityReporter: ActivityReporterProtocol
  private let autofillService: AutofillService
  private let onboardingAction: (OnboardingChecklistFlowViewModel.Action) -> Void
  private let completion: (VaultListCompletion) -> Void

  let itemsListViewModel: VaultItemsListViewModel

  private let filterPublisher = PassthroughSubject<ItemCategory?, Never>()

  init(
    vaultItemsStore: VaultItemsStore,
    userSettings: UserSettings,
    autofillService: AutofillService,
    lockService: LockServiceProtocol,
    onboardingAction: @escaping (OnboardingChecklistFlowViewModel.Action) -> Void,
    action: @escaping (VaultFlowViewModel.Action) -> Void,
    vaultItemsListFactory: VaultItemsListViewModel.Factory,
    homeBottomBannerFactory: HomeBottomBannerViewModel.Factory,
    homeTopBannerFactory: HomeTopBannerViewModel.Factory,
    lastpassDetector: LastpassDetector,
    sessionActivityReporter: ActivityReporterProtocol,
    completion: @escaping (VaultListCompletion) -> Void
  ) {
    self.completion = completion
    self.onboardingAction = onboardingAction
    self.homeBottomBannerFactory = homeBottomBannerFactory
    self.homeTopBannerFactory = homeTopBannerFactory
    self.autofillService = autofillService
    self.userSettings = userSettings
    self.vaultItemsStore = vaultItemsStore
    self.action = action
    self.isLastpassInstalled = lastpassDetector.isLastpassInstalled
    self.sessionActivityReporter = sessionActivityReporter
    self.vaultItemsListFactory = vaultItemsListFactory

    itemsListViewModel = vaultItemsListFactory.make(
      activeFilter: nil,
      activeFilterPublisher: filterPublisher.eraseToAnyPublisher(),
      completion: completion
    )
  }

  func makeHomeAnnouncementsViewModel() -> HomeTopBannerViewModel {
    homeTopBannerFactory.make(
      autofillBannerViewModel: .init { [weak self] action in
        switch action {
        case .showAutofillDemo:
          self?.action(.showAutofillDemo)
        }
      },
      isLastpassInstalled: isLastpassInstalled,
      credentialsCount: vaultItemsStore.credentials.count
    )
  }

  func makeHomeBottomBannerViewModel() -> HomeBottomBannerViewModel {
    homeBottomBannerFactory.make(action: action, onboardingAction: onboardingAction)
  }

  func filter(_ section: ItemCategory?) {
    filterPublisher.send(section)
  }
}

extension HomeListViewModel {
  static var mock: HomeListViewModel {
    .init(
      vaultItemsStore: MockVaultKitServicesContainer().vaultItemsStore,
      userSettings: .mock,
      autofillService: .fakeService,
      lockService: LockServiceMock(),
      onboardingAction: { _ in },
      action: { _ in },
      vaultItemsListFactory: .init { _, _, _ in .mock },
      homeBottomBannerFactory: .init { _, _ in .mock },
      homeTopBannerFactory: .init { _, _, _ in .mock },
      lastpassDetector: .mock,
      sessionActivityReporter: .mock,
      completion: { _ in }
    )
  }
}
