import Foundation
import DashTypes

class AuthenticatorNotificationRowViewModel: SessionServicesInjecting {
    let notification: DashlaneNotification
    let deepLinkingService: DeepLinkingServiceProtocol

    init(notification: DashlaneNotification,
         deepLinkingService: DeepLinkingServiceProtocol) {
        self.deepLinkingService = deepLinkingService
        self.notification = notification
    }

    func openAuthenticator() {
        deepLinkingService.handleLink(.tool(.authenticator))
    }
}

extension AuthenticatorNotificationRowViewModel {
    static var mock: AuthenticatorNotificationRowViewModel {
        .init(notification: AuthenticatorToolNotification(state: .seen,
                                                          creationDate: Date(),
                                                          notificationActionHandler: NotificationSettings.mock),
              deepLinkingService: DeepLinkingService.fakeService)
    }
}
