import Foundation

public struct ResetMasterPasswordIntroViewModel: HomeAnnouncementsServicesInjecting {

    let deepLinkingService: NotificationKitDeepLinkingServiceProtocol


    public init(deepLinkingService: NotificationKitDeepLinkingServiceProtocol) {
        self.deepLinkingService = deepLinkingService
    }

    func enable() {
        deepLinkingService.handle(.goToSettings(.enableResetMasterPassword))
    }
}

public extension ResetMasterPasswordIntroViewModel {
    static var mock: ResetMasterPasswordIntroViewModel {
        .init(deepLinkingService: NotificationKitDeepLinkingServiceMock())
    }
}
