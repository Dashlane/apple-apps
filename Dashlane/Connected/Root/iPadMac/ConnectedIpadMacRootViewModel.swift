import Combine
import DashTypes
import SwiftUI
import VaultKit

@MainActor
class ConnectedIpadMacRootViewModel: ObservableObject, SessionServicesInjecting {
  let deepLinkPublisher: AnyPublisher<DeepLink, Never>
  let sidebarViewModel: SidebarViewModel
  let notificationViewModel: NotificationsFlowViewModel
  let vaultFlowViewModels: [ItemCategory: VaultFlowViewModel]

  let homeFlowViewModelFactory: HomeFlowViewModel.Factory
  let toolsFlowViewModelFactory: ToolsFlowViewModel.Factory
  let settingsFlowViewModelFactory: SettingsFlowViewModel.Factory
  let collectionFlowViewModelFactory: CollectionsFlowViewModel.Factory

  @Published
  private(set) var selection: NavigationItem? = .home

  private var subscriptions: [AnyCancellable] = []

  init(
    deepLinkingService: DeepLinkingServiceProtocol,
    sidebarViewModelFactory: SidebarViewModel.Factory,
    homeFlowViewModelFactory: HomeFlowViewModel.Factory,
    notificationViewModelFactory: NotificationsFlowViewModel.Factory,
    vaultFlowModelFactory: VaultFlowViewModel.Factory,
    collectionFlowModelFactory: CollectionsFlowViewModel.Factory,
    toolsFlowViewModelFactory: ToolsFlowViewModel.Factory,
    settingsFlowViewModelFactory: SettingsFlowViewModel.Factory
  ) {
    self.deepLinkPublisher = deepLinkingService.deepLinkPublisher
    self.collectionFlowViewModelFactory = collectionFlowModelFactory
    self.toolsFlowViewModelFactory = toolsFlowViewModelFactory
    self.settingsFlowViewModelFactory = settingsFlowViewModelFactory

    self.sidebarViewModel = sidebarViewModelFactory.make()
    self.homeFlowViewModelFactory = homeFlowViewModelFactory
    self.notificationViewModel = notificationViewModelFactory.make()
    var vaultFlowViewModels: [ItemCategory: VaultFlowViewModel] = [:]
    for category in ItemCategory.allCases {
      vaultFlowViewModels[category] = vaultFlowModelFactory.make(itemCategory: category)
    }
    self.vaultFlowViewModels = vaultFlowViewModels

    sidebarViewModel.$selection.removeDuplicates().assign(to: &$selection)

    configureBadges()
  }

  private func configureBadges() {
    notificationViewModel.$unreadNotificationsCount.sink { [sidebarViewModel] value in
      sidebarViewModel.badgeValues[.notifications] = value
    }.store(in: &subscriptions)

    for category in ItemCategory.allCases {
      guard let model = vaultFlowViewModels[category] else {
        assertionFailure("vaultFlowViewModels should have been initialized")
        return
      }

      model.$categoryItemsCount.sink { [sidebarViewModel] value in
        sidebarViewModel.badgeValues[.vault(category)] = value
      }.store(in: &subscriptions)
    }
  }

  func select(_ item: NavigationItem) {
    sidebarViewModel.selection = item
  }

  func displaySettings() {
    sidebarViewModel.settingsDisplayed = true
  }

  func selection(for vault: VaultDeeplink) -> NavigationItem? {
    return vaultFlowViewModels.first { (_: ItemCategory, value: VaultFlowViewModel) in
      value.canHandle(deepLink: vault)
    }.map { (key: ItemCategory, _: _) in
      return .vault(key)
    }
  }
}
