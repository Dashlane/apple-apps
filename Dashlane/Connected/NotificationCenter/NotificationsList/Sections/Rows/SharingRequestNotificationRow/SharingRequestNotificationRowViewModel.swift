import Foundation
import CorePersonalData
import DashTypes

class SharingRequestNotificationRowViewModel: SessionServicesInjecting {
    let notification: DashlaneNotification
    let deepLinkingService: DeepLinkingServiceProtocol

    init(notification: DashlaneNotification,
         deepLinkingService: DeepLinkingServiceProtocol) {
        self.deepLinkingService = deepLinkingService
        self.notification = notification
    }

    func openSharingCenter() {
        deepLinkingService.handleURL(URL(string: "dashlanenavigator:///contacts/sharing/")!)
    }
}

extension SharingRequestNotificationRowViewModel {
    static var mock: SharingRequestNotificationRowViewModel {
        .init(notification: SharingRequestNotification(state: .seen,
                                                       creationDate: Date(),
                                                       notificationActionHandler: NotificationSettings.mock,
                                                       vaultItem: Credential(),
                                                       referrer: "Rayane",
                                                       requestId: "test",
                                                       settingsPrefix: "test"),
              deepLinkingService: DeepLinkingService.fakeService)
    }
}
