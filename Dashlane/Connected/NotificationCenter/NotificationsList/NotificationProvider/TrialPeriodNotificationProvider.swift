import Combine
import CoreFeature
import CorePremium
import CoreSettings
import DesignSystem
import Foundation
import SwiftTreats
import SwiftUI

class TrialPeriodNotificationProvider: NotificationProvider {
  private let settingsPrefix: String = "trial-period-item-identifier"
  private let premiumStatusProvider: PremiumStatusProvider
  private let abTestService: ABTestingServiceProtocol
  private let settings: NotificationSettings

  init(
    premiumStatusProvider: PremiumStatusProvider,
    abTestService: ABTestingServiceProtocol,
    settingsStore: LocalSettingsStore
  ) {
    self.premiumStatusProvider = premiumStatusProvider
    self.abTestService = abTestService
    self.settings = NotificationSettings(
      prefix: settingsPrefix,
      settings: settingsStore)
  }

  public func notificationPublisher() -> AnyPublisher<[DashlaneNotification], Never> {
    return premiumStatusProvider
      .statusPublisher
      .receive(on: DispatchQueue.main)
      .combineLatest(settings.settingsChangePublisher())
      .map { [weak self] premiumStatus, _ -> [TrialPeriodNotification] in
        guard let self = self,
          self.shouldBeDisplayed(for: premiumStatus)
        else { return [] }
        return [
          TrialPeriodNotification(
            state: self.settings.fetchState(),
            creationDate: self.settings.creationDate,
            notificationActionHandler: self.settings)
        ]
      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }

  func shouldBeDisplayed(for premiumStatus: CorePremium.Status) -> Bool {
    guard premiumStatus.b2bStatus?.statusCode != .inTeam else {
      return false
    }
    return premiumStatus.b2cStatus.isTrial && premiumStatus.b2cStatus.statusCode == .subscribed
  }
}

struct TrialPeriodNotification: DashlaneNotification {
  let state: NotificationCenterService.Notification.State
  let icon: SwiftUI.Image = .ds.premium.outlined
  let title: String = L10n.Localizable.actionItemFreeTrialStartedTitle
  let description: String = L10n.Localizable.actionItemFreeTrialStartedDescription
  let category: NotificationCategory = .yourAccount
  let id: String = "trialPeriod"
  let notificationActionHandler: NotificationActionHandler
  let kind: NotificationCenterService.Notification = .static(.trialPeriod)
  let creationDate: Date

  init(
    state: NotificationCenterService.Notification.State,
    creationDate: Date,
    notificationActionHandler: NotificationActionHandler
  ) {
    self.creationDate = creationDate
    self.state = state
    self.notificationActionHandler = notificationActionHandler
  }
}
