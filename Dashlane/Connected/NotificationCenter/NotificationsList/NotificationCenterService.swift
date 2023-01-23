import Foundation
import Combine
import CoreSync
import CoreSession
import CoreUserTracking
import DashlaneAppKit
import CoreSettings
import CoreFeature
import DashTypes
import CoreKeychain
import LoginKit
import VaultKit

public class NotificationCenterServicePublishersStore {
    @Published
    var notifications: [DashlaneNotification]

    @Published
    var unreadNotificationsCount: Int

    init(notifications: [DashlaneNotification] = [],
         unreadNotificationsCount: Int = 0) {
        self.notifications = notifications
        self.unreadNotificationsCount = unreadNotificationsCount
    }
}

public final class NotificationCenterService: NotificationCenterServicePublishersStore, Mockable, SessionServicesInjecting {
    private let actionItemCenterLogger: NotificationCenterLogger
    private let notificationProviders: [NotificationProvider]

    init(session: Session,
         settings: LocalSettingsStore,
         userSettings: UserSettings,
         lockService: LockServiceProtocol,
         premiumService: PremiumServiceProtocol,
         identityDashboardService: IdentityDashboardServiceProtocol,
         resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
         usageLogService: UsageLogServiceProtocol,
         sharingService: SharingServiceProtocol,
         teamspaceService: TeamSpacesService,
         abtestService: AuthenticatedABTestingService,
         keychainService: AuthenticationKeychainServiceProtocol,
         featureService: FeatureServiceProtocol) {

        self.actionItemCenterLogger = .init(usageLogService: usageLogService)
        self.notificationProviders = [
            ResetMasterPasswordNotificationProvider(keychainService: keychainService,
                                                    featureService: featureService,
                                                    resetMasterPasswordService: resetMasterPasswordService,
                                                    userSettings: userSettings,
                                                    teamSpaceService: teamspaceService,
                                                    settingsStore: settings,
                                                    logger: actionItemCenterLogger),
            SecureLockNotificationProvider(lockService: lockService,
                                           settingsStore: settings,
                                           logger: actionItemCenterLogger),
            TrialPeriodNotificationProvider(premiumService: premiumService,
                                            abTestService: abtestService,
                                            settingsStore: settings,
                                            logger: actionItemCenterLogger),
            SharingItemGroupNotificationProvider(session: session,
                                                 sharingService: sharingService,
                                                 featureService: featureService,
                                                 settingsStore: settings,
                                                 logger: actionItemCenterLogger),
            SharingUserGroupNotificationProvider(session: session,
                                                 sharingService: sharingService,
                                                 featureService: featureService,
                                                 settingsStore: settings,
                                                 logger: actionItemCenterLogger),
            SecurityAlertNotificationProvider(identityDashboardService: identityDashboardService,
                                              settingsStore: settings,
                                              logger: actionItemCenterLogger),
            AuthenticatorToolNotificationProvider(userSettings: userSettings,
                                                  featureService: featureService,
                                                  settingsStore: settings,
                                                  logger: actionItemCenterLogger)
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
