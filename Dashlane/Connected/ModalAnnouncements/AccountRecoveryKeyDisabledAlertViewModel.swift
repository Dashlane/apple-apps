import CoreSession
import Foundation
import NotificationKit

class AccountRecoveryKeyDisabledAlertViewModel: SessionServicesInjecting {
  let authenticationMethod: AuthenticationMethod
  let deeplinkService: DeepLinkingServiceProtocol

  init(
    authenticationMethod: AuthenticationMethod,
    deeplinkService: DeepLinkingServiceProtocol
  ) {
    self.authenticationMethod = authenticationMethod
    self.deeplinkService = deeplinkService
  }

  func goToSettings() {
    deeplinkService.handleLink(.settings(.security(.recoveryKey)))
  }
}
