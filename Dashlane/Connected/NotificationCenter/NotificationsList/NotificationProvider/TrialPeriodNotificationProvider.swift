import SwiftUI
import Foundation
import DashlaneAppKit
import SwiftTreats
import Combine
import CoreFeature
import CorePremium
import CoreSettings

class TrialPeriodNotificationProvider: NotificationProvider {
    private let settingsPrefix: String = "trial-period-item-identifier"
    private let premiumService: PremiumServiceProtocol
    private let abTestService: ABTestingServiceProtocol
    private let settings: NotificationSettings

    init(premiumService: PremiumServiceProtocol,
         abTestService: ABTestingServiceProtocol,
         settingsStore: LocalSettingsStore) {
        self.premiumService = premiumService
        self.abTestService = abTestService
        self.settings = NotificationSettings(prefix: settingsPrefix,
                                             settings: settingsStore)
    }

        public func notificationPublisher() -> AnyPublisher<[DashlaneNotification], Never> {
        return premiumService
            .statusPublisher
            .combineLatest(settings.settingsChangePublisher())
            .map { [weak self] premiumStatus, _ -> [TrialPeriodNotification] in
                guard let self = self,
                      self.shouldBeDisplayed(premiumStatus: premiumStatus) else { return [] }
                return [TrialPeriodNotification(state: self.settings.fetchState(),
                                                creationDate: self.settings.creationDate,
                                                notificationActionHandler: self.settings)]
            }
            .eraseToAnyPublisher()
    }

    func shouldBeDisplayed(premiumStatus: PremiumStatus?) -> Bool {
        guard let statusCode = premiumStatus?.statusCode else {
            return false
        }
        return statusCode == .freeTrial
    }
}

struct TrialPeriodNotification: DashlaneNotification {
    let state: NotificationCenterService.Notification.State
    let icon: SwiftUI.Image = Image(asset: FiberAsset.actionItemDiamond)
    let title: String = L10n.Localizable.actionItemFreeTrialStartedTitle
    let description: String = L10n.Localizable.actionItemFreeTrialStartedDescription
    let category: NotificationCategory = .yourAccount
    let id: String = "trialPeriod"
    let notificationActionHandler: NotificationActionHandler
    let kind: NotificationCenterService.Notification = .static(.trialPeriod)
    let creationDate: Date

    init(state: NotificationCenterService.Notification.State,
         creationDate: Date,
         notificationActionHandler: NotificationActionHandler) {
        self.creationDate = creationDate
        self.state = state
        self.notificationActionHandler = notificationActionHandler
    }
}
