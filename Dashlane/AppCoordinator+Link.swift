import Foundation

extension AppCoordinator {
  func didReceiveDeepLink(_ deepLink: DeepLink) {
    switch deepLink {
    case .userNotConnected(let userNotConnectedDeepLink):
      switch userNotConnectedDeepLink {
      case .accountCreationFromAuthenticator:
        showOnboarding()
      default:
        break
      }
      self.appServices.deepLinkingService.resetLastLink()
    default: break
    }
  }
}
