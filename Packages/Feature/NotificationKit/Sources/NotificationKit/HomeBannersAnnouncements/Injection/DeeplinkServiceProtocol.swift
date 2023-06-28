import Foundation
import CorePremium

public enum DeepLinkAction {

    public enum Settings {
        case root
        case recoveryKey
        case enableResetMasterPassword
    }

    case goToPremium
    case displayPaywall(CapabilityKey)
    case goToSettings(Settings)
    case importFromLastPass
}

public protocol NotificationKitDeepLinkingServiceProtocol {
    func handleURL(_ url: URL)
    func handle(_ action: DeepLinkAction)
}

public struct NotificationKitDeepLinkingServiceMock: NotificationKitDeepLinkingServiceProtocol {
    public init() { }
    public func handleURL(_ url: URL) {

    }
    public func handle(_ action: DeepLinkAction) {

    }
}
