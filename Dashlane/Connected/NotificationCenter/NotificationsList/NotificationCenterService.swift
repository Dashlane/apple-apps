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
import CorePremium

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
    private let notificationProviders: [NotificationProvider]

    init(session: Session,
         settings: LocalSettingsStore,
         userSettings: UserSettings,
         lockService: LockServiceProtocol,
         premiumService: PremiumServiceProtocol,
         identityDashboardService: IdentityDashboardServiceProtocol,
         resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
         sharingService: SharingServiceProtocol,
         teamspaceService: TeamSpacesService,
         abtestService: AuthenticatedABTestingService,
         keychainService: AuthenticationKeychainServiceProtocol,
         featureService: FeatureServiceProtocol) {

        self.notificationProviders = [
            ResetMasterPasswordNotificationProvider(session: session,
                                                    keychainService: keychainService,
                                                    featureService: featureService,
                                                    resetMasterPasswordService: resetMasterPasswordService,
                                                    userSettings: userSettings,
                                                    teamSpaceService: teamspaceService,
                                                    settingsStore: settings),
            SecureLockNotificationProvider(lockService: lockService,
                                           settingsStore: settings),
            TrialPeriodNotificationProvider(premiumService: premiumService,
                                            abTestService: abtestService,
                                            settingsStore: settings),
            SharingItemGroupNotificationProvider(session: session,
                                                 sharingService: sharingService,
                                                 featureService: featureService,
                                                 settingsStore: settings),
            SharingUserGroupNotificationProvider(session: session,
                                                 sharingService: sharingService,
                                                 featureService: featureService,
                                                 settingsStore: settings),
            SecurityAlertNotificationProvider(identityDashboardService: identityDashboardService,
                                              settingsStore: settings),
            AuthenticatorToolNotificationProvider(userSettings: userSettings,
                                                  featureService: featureService,
                                                  settingsStore: settings)
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
