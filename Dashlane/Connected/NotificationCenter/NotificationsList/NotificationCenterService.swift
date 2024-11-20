import Combine
import CoreFeature
import CoreKeychain
import CorePremium
import CoreSession
import CoreSettings
import CoreSync
import CoreUserTracking
import DashTypes
import Foundation
import LoginKit
import VaultKit

public class NotificationCenterServicePublishersStore {
  @Published
  var notifications: [DashlaneNotification]

  @Published
  var unreadNotificationsCount: Int

  init(
    notifications: [DashlaneNotification] = [],
    unreadNotificationsCount: Int = 0
  ) {
    self.notifications = notifications
    self.unreadNotificationsCount = unreadNotificationsCount
  }
}

public final class NotificationCenterService: NotificationCenterServicePublishersStore,
  SessionServicesInjecting, NotificationCenterServiceProtocol
{
  private let notificationProviders: [NotificationProvider]

  init(
    session: Session,
    settings: LocalSettingsStore,
    userSettings: UserSettings,
    lockService: LockServiceProtocol,
    premiumStatusProvider: PremiumStatusProvider,
    identityDashboardService: IdentityDashboardServiceProtocol,
    resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
    sharingService: SharingServiceProtocol,
    userSpacesService: UserSpacesService,
    abtestService: AuthenticatedABTestingService,
    keychainService: AuthenticationKeychainServiceProtocol,
    featureService: FeatureServiceProtocol,
    vaultStateService: VaultStateServiceProtocol
  ) {

    self.notificationProviders = [
      ResetMasterPasswordNotificationProvider(
        session: session,
        keychainService: keychainService,
        featureService: featureService,
        resetMasterPasswordService: resetMasterPasswordService,
        userSettings: userSettings,
        settingsStore: settings),
      SecureLockNotificationProvider(
        lockService: lockService,
        settingsStore: settings),
      TrialPeriodNotificationProvider(
        premiumStatusProvider: premiumStatusProvider,
        abTestService: abtestService,
        settingsStore: settings),
      SharingItemGroupNotificationProvider(
        session: session,
        sharingService: sharingService,
        featureService: featureService,
        settingsStore: settings),
      SharingUserGroupNotificationProvider(
        session: session,
        sharingService: sharingService,
        featureService: featureService,
        settingsStore: settings),
      SharingCollectionNotificationProvider(
        session: session,
        sharingService: sharingService,
        featureService: featureService,
        settingsStore: settings),
      SecurityAlertNotificationProvider(
        identityDashboardService: identityDashboardService,
        settingsStore: settings),
      FrozenAccoutNotificationProvider(
        vaultStateService: vaultStateService,
        settingsStore: settings),
    ]

    super.init()
    setupPublisher()
  }

  func setupPublisher() {
    notificationProviders
      .map { $0.notificationPublisher() }
      .combineLatest()
      .map { $0.flatMap { $0 } }
      .assign(to: &$notifications)

    $notifications
      .map { notifications -> Int in
        notifications.filter { $0.state == .unseen }.count
      }
      .assign(to: &$unreadNotificationsCount)
  }
}
