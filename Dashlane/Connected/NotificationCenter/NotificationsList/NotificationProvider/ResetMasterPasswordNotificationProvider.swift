import Combine
import CoreFeature
import CoreKeychain
import CoreSession
import CoreSettings
import CoreTypes
import Foundation
import LoginKit
import SwiftTreats
import SwiftUI

class ResetMasterPasswordNotificationProvider: NotificationProvider {
  private let settingsPrefix: String = "reset-master-password-action-item-identifier"
  private let keychainService: AuthenticationKeychainServiceProtocol
  private let featureService: FeatureServiceProtocol
  private let resetMasterPasswordService: ResetMasterPasswordServiceProtocol
  private let userSettings: UserSettings
  private let settings: NotificationSettings
  private let authenticationMethod: AuthenticationMethod

  init(
    session: Session,
    keychainService: AuthenticationKeychainServiceProtocol,
    featureService: FeatureServiceProtocol,
    resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
    userSettings: UserSettings,
    settingsStore: LocalSettingsStore
  ) {
    self.authenticationMethod = session.authenticationMethod
    self.featureService = featureService
    self.keychainService = keychainService
    self.resetMasterPasswordService = resetMasterPasswordService
    self.userSettings = userSettings
    self.settings = NotificationSettings(
      prefix: settingsPrefix,
      settings: settingsStore)
  }

  public func notificationPublisher() -> AnyPublisher<[DashlaneNotification], Never> {
    return resetMasterPasswordService.activationStatusPublisher()
      .prepend(resetMasterPasswordService.isActive)
      .combineLatest(settings.settingsChangePublisher())
      .map { [weak self] _, _ -> [ResetMasterPasswordNotification] in
        guard let self = self,
          self.shouldBeDisplayed
        else { return [] }
        return [
          ResetMasterPasswordNotification(
            state: self.settings.fetchState(),
            creationDate: self.settings.creationDate,
            notificationActionHandler: self.settings)
        ]
      }
      .eraseToAnyPublisher()
  }

  private var shouldBeDisplayed: Bool {
    guard canAuthenticateUsingBiometrics else { return false }
    guard case .masterPassword = authenticationMethod else { return false }
    guard featureService.isEnabled(.masterPasswordResetIsAvailable) else { return false }
    return !resetMasterPasswordService.isActive
  }

  private var canAuthenticateUsingBiometrics: Bool {
    return Device.biometryType != nil
  }
}

struct ResetMasterPasswordNotification: DashlaneNotification {
  let state: NotificationCenterService.Notification.State
  let icon = Image(.Notification.resetMasterPasswordActionItemIcon)
  let title = L10n.Localizable.resetMasterPasswordNotificationCenterItemTitle
  let description = L10n.Localizable.resetMasterPasswordNotificationCenterItemTitle
  let category: NotificationCategory = .gettingStarted
  let id: String = "resetMasterPassword"
  let notificationActionHandler: NotificationActionHandler
  let kind: NotificationCenterService.Notification = .static(.resetMasterPassword)
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
