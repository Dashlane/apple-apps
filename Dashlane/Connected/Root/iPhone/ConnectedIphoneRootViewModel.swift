import Combine
import Foundation

@MainActor
class ConnectedIphoneRootViewModel: ObservableObject, SessionServicesInjecting {
  let deepLinkPublisher: AnyPublisher<DeepLink, Never>
  let homeFlowViewModelFactory: HomeFlowViewModel.Factory
  let notificationViewModelFactory: NotificationsFlowViewModel.Factory
  let passwordGeneratorToolsFlowViewModelFactory: PasswordGeneratorToolsFlowViewModel.Factory
  let toolsFlowViewModelFactory: ToolsFlowViewModel.Factory
  let settingsFlowViewModelFactory: SettingsFlowViewModel.Factory

  init(
    deepLinkingService: DeepLinkingServiceProtocol,
    homeFlowViewModelFactory: HomeFlowViewModel.Factory,
    notificationViewModelFactory: NotificationsFlowViewModel.Factory,
    passwordGeneratorToolsFlowViewModelFactory: PasswordGeneratorToolsFlowViewModel.Factory,
    toolsFlowViewModelFactory: ToolsFlowViewModel.Factory,
    settingsFlowViewModelFactory: SettingsFlowViewModel.Factory
  ) {
    self.deepLinkPublisher = deepLinkingService.deepLinkPublisher

    self.homeFlowViewModelFactory = homeFlowViewModelFactory
    self.notificationViewModelFactory = notificationViewModelFactory
    self.passwordGeneratorToolsFlowViewModelFactory = passwordGeneratorToolsFlowViewModelFactory
    self.toolsFlowViewModelFactory = toolsFlowViewModelFactory
    self.settingsFlowViewModelFactory = settingsFlowViewModelFactory
  }
}
