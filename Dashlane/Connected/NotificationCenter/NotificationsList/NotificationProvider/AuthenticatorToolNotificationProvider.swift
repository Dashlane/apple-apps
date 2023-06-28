import Foundation
import DashlaneAppKit
import CoreSettings
import Combine
import CoreFeature
import DesignSystem
import SwiftUI

struct AuthenticatorToolNotification: DashlaneNotification {

    let id = "AuthenticatorTool"
    let state: NotificationCenterService.Notification.State
    let icon = Image.ds.feature.authenticator.outlined
    let title = L10n.Localizable.authenticatorToolOnboardingActionItemTitle
    let description = L10n.Localizable.authenticatorToolOnboardingActionItemDescription
    let category: NotificationCategory = .whatIsNew
    let kind: NotificationCenterService.Notification = .static(.authenticatorTool)

    let creationDate: Date
    let notificationActionHandler: NotificationActionHandler

    init(state: NotificationCenterService.Notification.State,
         creationDate: Date,
         notificationActionHandler: NotificationActionHandler) {
        self.creationDate = creationDate
        self.state = state
        self.notificationActionHandler = notificationActionHandler
    }

}

class AuthenticatorToolNotificationProvider: NotificationProvider {
    private let settingsPrefix: String = "authenticator-item-identifier"
    private let userSettings: UserSettings
    private let featureService: FeatureServiceProtocol
    private let settings: NotificationSettings

    init(userSettings: UserSettings,
         featureService: FeatureServiceProtocol,
         settingsStore: LocalSettingsStore) {
        self.userSettings = userSettings
        self.featureService = featureService
        self.settings = NotificationSettings(prefix: settingsPrefix,
                                             settings: settingsStore)
    }

    public func notificationPublisher() -> AnyPublisher<[DashlaneNotification], Never> {
        settings.settingsChangePublisher()
            .map { [settings, featureService] in
                let notification = AuthenticatorToolNotification(state: settings.fetchState(),
                                                                 creationDate: settings.creationDate,
                                                                 notificationActionHandler: settings)
                return featureService.isEnabled(.authenticatorTool) ? [notification] : []
            }
            .eraseToAnyPublisher()
    }
}
