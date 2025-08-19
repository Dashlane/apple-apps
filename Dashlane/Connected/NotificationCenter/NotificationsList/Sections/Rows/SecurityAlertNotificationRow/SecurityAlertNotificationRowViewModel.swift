import CorePersonalData
import CoreTypes
import Foundation

class SecurityAlertNotificationRowViewModel: SessionServicesInjecting {
  let notification: DashlaneNotification
  private let deepLinkingService: DeepLinkingServiceProtocol

  init(
    notification: DashlaneNotification,
    deepLinkingService: DeepLinkingServiceProtocol
  ) {
    self.notification = notification
    self.deepLinkingService = deepLinkingService
  }

  func openUnresolvedAlert() {
    guard case let .dynamic(dynamicNotification) = notification.kind,
      case let .securityAlert(unresolvedAlert) = dynamicNotification
    else { return }
    deepLinkingService.handleLink(.unresolvedAlert(unresolvedAlert.alert))
  }
}

extension SecurityAlertNotificationRowViewModel {
  static var mock: SecurityAlertNotificationRowViewModel {
    .init(
      notification: SecurityAlertNotification(
        state: .seen,
        creationDate: Date(),
        notificationActionHandler: NotificationSettings.mock,
        unresolvedAlert: UnresolvedAlert.mock,
        settingsPrefix: "",
        type: .breachAlert,
        dismissAction: {}
      ),
      deepLinkingService: DeepLinkingService.fakeService
    )
  }
}
