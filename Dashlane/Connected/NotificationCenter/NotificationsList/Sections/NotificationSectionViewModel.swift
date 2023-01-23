import Foundation
import DashlaneAppKit
import SwiftTreats

class NotificationSectionViewModel {
    let notificationCenterService: NotificationCenterServiceProtocol
    let dataSection: NotificationDataSection
    let shouldShowHeader: Bool
    let isTruncated: Bool
    private let resetMasterPasswordNotificationFactory: (DashlaneNotification) -> ResetMasterPasswordNotificationRowViewModel
    private let trialPeriodNotificationFactory: (DashlaneNotification) -> TrialPeriodNotificationRowViewModel
    private let secureLockNotificationFactory: (DashlaneNotification) -> SecureLockNotificationRowViewModel
    private let authenticatorNotificationFactory: (DashlaneNotification) -> AuthenticatorNotificationRowViewModel
    private let sharingItemNotificationFactory: (DashlaneNotification) -> SharingRequestNotificationRowViewModel
    private let securityAlertNotificationFactory: (DashlaneNotification) -> SecurityAlertNotificationRowViewModel
    let didTapSeeAll: () -> Void

    var displayableNotifications: [DashlaneNotification] {
        isTruncated ? Array(dataSection.notifications.prefix(2)) : dataSection.notifications
    }

    init(notificationCenterService: NotificationCenterServiceProtocol,
         dataSection: NotificationDataSection,
         shouldShowHeader: Bool = true,
         isTruncated: Bool = true,
         authenticatorNotificationFactory: @escaping (DashlaneNotification) -> AuthenticatorNotificationRowViewModel,
         resetMasterPasswordNotificationFactory: @escaping (DashlaneNotification) -> ResetMasterPasswordNotificationRowViewModel,
         trialPeriodNotificationFactory: @escaping (DashlaneNotification) -> TrialPeriodNotificationRowViewModel,
         secureLockNotificationFactory: @escaping (DashlaneNotification) -> SecureLockNotificationRowViewModel,
         sharingItemNotificationFactory: @escaping (DashlaneNotification) -> SharingRequestNotificationRowViewModel,
         securityAlertNotificationFactory: @escaping (DashlaneNotification) -> SecurityAlertNotificationRowViewModel,
         didTapSeeAll: @escaping () -> Void) {
        self.trialPeriodNotificationFactory = trialPeriodNotificationFactory
        self.securityAlertNotificationFactory = securityAlertNotificationFactory
        self.authenticatorNotificationFactory = authenticatorNotificationFactory
        self.resetMasterPasswordNotificationFactory = resetMasterPasswordNotificationFactory
        self.sharingItemNotificationFactory = sharingItemNotificationFactory
        self.didTapSeeAll = didTapSeeAll
        self.secureLockNotificationFactory = secureLockNotificationFactory
        self.isTruncated = isTruncated
        self.dataSection = dataSection
        self.shouldShowHeader = shouldShowHeader
        self.notificationCenterService = notificationCenterService
    }

    func categoryListViewModel() -> NotificationsCategoryListViewModel {
        return .init(section: dataSection,
                     notificationCenterService: notificationCenterService, authenticatorNotificationFactory: authenticatorNotificationFactory,
                     resetMasterPasswordNotificationFactory: resetMasterPasswordNotificationFactory,
                     trialPeriodNotificationFactory: trialPeriodNotificationFactory,
                     secureLockNotificationFactory: secureLockNotificationFactory,
                     sharingItemNotificationFactory: sharingItemNotificationFactory,
                     securityAlertNotificationFactory: securityAlertNotificationFactory)
    }

    func authenticatorViewModel(_ notification: DashlaneNotification) -> AuthenticatorNotificationRowViewModel {
        return authenticatorNotificationFactory(notification)
    }

    func resetMasterPasswordViewModel(_ notification: DashlaneNotification) -> ResetMasterPasswordNotificationRowViewModel {
        return resetMasterPasswordNotificationFactory(notification)
    }

    func trialPeriodViewModel(_ notification: DashlaneNotification) -> TrialPeriodNotificationRowViewModel {
        return trialPeriodNotificationFactory(notification)
    }

    func secureLockPasswordViewModel(_ notification: DashlaneNotification) -> SecureLockNotificationRowViewModel {
        return secureLockNotificationFactory(notification)
    }

    func sharingItemViewModel(_ notification: DashlaneNotification) -> SharingRequestNotificationRowViewModel {
        return sharingItemNotificationFactory(notification)
    }

    func securityAlertViewModel(_ notification: DashlaneNotification) -> SecurityAlertNotificationRowViewModel {
        return securityAlertNotificationFactory(notification)
    }
}

@MainActor
extension NotificationSectionViewModel {
    private static let notifications: [DashlaneNotification] = [
        ResetMasterPasswordNotification(state: .seen, creationDate: Date(), notificationActionHandler: NotificationSettings.mock),
        ResetMasterPasswordNotification(state: .dismissed, creationDate: Date(), notificationActionHandler: NotificationSettings.mock),
        ResetMasterPasswordNotification(state: .unseen, creationDate: Date(), notificationActionHandler: NotificationSettings.mock)
    ]

    static var mock: NotificationSectionViewModel {
        .init(notificationCenterService: NotificationCenterService.mock,
              dataSection: .init(category: .gettingStarted, notifications: notifications),
              authenticatorNotificationFactory: {_ in
            AuthenticatorNotificationRowViewModel.mock},
              resetMasterPasswordNotificationFactory: {_ in ResetMasterPasswordNotificationRowViewModel.mock},
              trialPeriodNotificationFactory: {_ in TrialPeriodNotificationRowViewModel.mock},
              secureLockNotificationFactory: {_ in SecureLockNotificationRowViewModel.mock},
              sharingItemNotificationFactory: {_ in SharingRequestNotificationRowViewModel.mock},
              securityAlertNotificationFactory: {_ in SecurityAlertNotificationRowViewModel.mock}, didTapSeeAll: {})
    }
}
