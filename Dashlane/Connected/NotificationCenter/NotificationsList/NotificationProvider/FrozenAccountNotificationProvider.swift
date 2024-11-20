import Combine
import CoreFeature
import CoreLocalization
import CoreSettings
import DesignSystem
import Foundation
import SwiftTreats
import SwiftUI

class FrozenAccoutNotificationProvider: NotificationProvider {
  private let settingsPrefix: String = "frozen-account-item-identifier"
  private let vaultStateService: VaultStateServiceProtocol
  private let settings: NotificationSettings

  init(
    vaultStateService: VaultStateServiceProtocol,
    settingsStore: LocalSettingsStore
  ) {
    self.vaultStateService = vaultStateService
    self.settings = NotificationSettings(
      prefix: settingsPrefix,
      settings: settingsStore)
  }

  public func notificationPublisher() -> AnyPublisher<[DashlaneNotification], Never> {
    return self.vaultStateService
      .vaultStatePublisher()
      .receive(on: DispatchQueue.main)
      .map { vaultState in
        switch vaultState {
        case .default: return []
        case .frozen:
          return [
            FrozenAccountNotification(
              state: self.settings.fetchState(),
              creationDate: self.settings.creationDate,
              notificationActionHandler: self.settings)
          ]
        }
      }
      .eraseToAnyPublisher()
  }
}

struct FrozenAccountNotification: DashlaneNotification {

  let state: NotificationCenterService.Notification.State
  let creationDate: Date
  let notificationActionHandler: NotificationActionHandler

  let icon: Image = Image.ds.notification.outlined
  let title: String = CoreLocalization.L10n.Core.notificationFrozenAccountTitle
  let description: String = CoreLocalization.L10n.Core.notificationFrozenAccountDescription

  let category: NotificationCategory = .whatIsNew
  let id: String = "frozenAccount"
  let kind: NotificationCenterService.Notification = .static(.frozenAccount)

  init(
    state: NotificationCenterService.Notification.State,
    creationDate: Date,
    notificationActionHandler: NotificationActionHandler
  ) {
    self.state = state
    self.creationDate = creationDate
    self.notificationActionHandler = notificationActionHandler
  }
}
