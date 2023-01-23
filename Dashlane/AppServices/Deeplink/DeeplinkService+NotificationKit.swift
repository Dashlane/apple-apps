import Foundation
import NotificationKit

extension DeepLinkingService: NotificationKitDeepLinkingServiceProtocol {

    func handle(_ action: DeepLinkAction) {
        switch action {
        case let .goToSettings(component):
            switch component {
            case .root:
                return self.handleLink(.settings(.root))
            case .enableResetMasterPassword:
                return self.handleLink(.settings(.security(.enableResetMasterPassword)))
            }
        case .goToPremium:
            handleLink(.other(.getPremium))
        case let .displayPaywall(capability):
            handleLink(.planPurchase(initialView: .paywall(key: capability)))
        }
    }
}
