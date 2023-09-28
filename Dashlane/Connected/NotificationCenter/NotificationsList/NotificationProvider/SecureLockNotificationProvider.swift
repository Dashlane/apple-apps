import Foundation
import DashlaneAppKit
import SwiftTreats
import Combine
import SwiftUI
import CoreSettings
import DesignSystem

class SecureLockNotificationProvider: NotificationProvider {
    private let settingsPrefix: String = "secure-lock-action-item-identifier"
    private let lockService: LockServiceProtocol
    private let settings: NotificationSettings

    init(lockService: LockServiceProtocol,
         settingsStore: LocalSettingsStore) {
        self.lockService = lockService
        self.settings = NotificationSettings(prefix: settingsPrefix,
                                             settings: settingsStore)
    }

        public func notificationPublisher() -> AnyPublisher<[DashlaneNotification], Never> {
        return lockService
            .secureLockModePublisher()
            .prepend(lockService.secureLockMode())
            .combineLatest(settings.settingsChangePublisher())
            .map { [settings] secureLockMode, _ -> [SecureLockNotification] in
                guard secureLockMode == .masterKey else { return [] }
                return [SecureLockNotification(state: settings.fetchState(),
                                               creationDate: settings.creationDate,
                                               notificationActionHandler: settings)]
            }
            .eraseToAnyPublisher()
    }
}

struct SecureLockNotification: DashlaneNotification {
    let state: NotificationCenterService.Notification.State
    let icon: SwiftUI.Image
    let title: String
    let description: String
    let category: NotificationCategory = .gettingStarted
    let id: String = "secureLock"
    let notificationActionHandler: NotificationActionHandler
    let kind: NotificationCenterService.Notification = .static(.secureLock)
    let creationDate: Date

    init(state: NotificationCenterService.Notification.State,
         creationDate: Date,
         notificationActionHandler: NotificationActionHandler) {
        self.state = state
        self.creationDate = creationDate
        self.notificationActionHandler = notificationActionHandler

        switch Device.biometryType {
        case .touchId:
            title = L10n.Localizable.announceBiometryTypeCta(Device.currentBiometryDisplayableName)
            description = L10n.Localizable.actionItemSecureLockDetailTouchid
            icon = Image.ds.fingerprint.outlined
        case .faceId:
            title = L10n.Localizable.announceBiometryTypeCta(Device.currentBiometryDisplayableName)
            description = L10n.Localizable.actionItemSecureLockDetailFaceid
            icon = Image.ds.faceId.outlined
        default:
            title = L10n.Localizable.announcePinCta
            description = L10n.Localizable.actionItemSecureLockDetailPin
            icon = Image(asset: FiberAsset.pinActionItemIcon)
        }

    }
}
