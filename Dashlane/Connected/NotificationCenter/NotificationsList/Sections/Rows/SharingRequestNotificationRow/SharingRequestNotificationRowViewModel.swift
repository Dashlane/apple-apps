import CorePersonalData
import DashTypes
import Foundation

class SharingRequestNotificationRowViewModel: SessionServicesInjecting {
  let notification: DashlaneNotification
  let deepLinkingService: DeepLinkingServiceProtocol

  init(
    notification: DashlaneNotification,
    deepLinkingService: DeepLinkingServiceProtocol
  ) {
    self.deepLinkingService = deepLinkingService
    self.notification = notification
  }

  func openSharingCenter() {
    deepLinkingService.handleURL(URL(string: "dashlanenavigator:///contacts/sharing/")!)
  }
}

extension SharingRequestNotificationRowViewModel {
  static var mock: SharingRequestNotificationRowViewModel {
    .init(
      notification: SharingRequestNotification(
        state: .seen,
        creationDate: Date(),
        notificationActionHandler: NotificationSettings.mock,
        kind: .item(Credential()),
        referrer: "Rayane",
        requestId: "test",
        settingsPrefix: "test"
      ),
      deepLinkingService: DeepLinkingService.fakeService
    )
  }
}
