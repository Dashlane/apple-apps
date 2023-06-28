import Foundation
import Combine
import CoreSync
import CoreSession
import CoreUserTracking
import DashlaneAppKit
import CoreSettings
import CoreFeature
import CoreKeychain
import LoginKit
import DashTypes
import CorePremium

class NotificationsListViewModel: ObservableObject, SessionServicesInjecting {

    enum Step {
        case list
        case category(NotificationsCategoryListViewModel)
    }

    @Published
    var sections: [NotificationDataSection] = []

    @Published
    var steps: [Step] = [.list]

    private let notificationCenterService: NotificationCenterServiceProtocol

    private let authenticatorNotificationFactory: (DashlaneNotification) -> AuthenticatorNotificationRowViewModel
    private let resetMasterPasswordNotificationFactory: (DashlaneNotification) -> ResetMasterPasswordNotificationRowViewModel
    private let trialPeriodNotificationFactory: (DashlaneNotification) -> TrialPeriodNotificationRowViewModel
    private let secureLockNotificationFactory: (DashlaneNotification) -> SecureLockNotificationRowViewModel
    private let sharingItemNotificationFactory: (DashlaneNotification) -> SharingRequestNotificationRowViewModel
    private let securityAlertNotificationFactory: (DashlaneNotification) -> SecurityAlertNotificationRowViewModel
    private let computingQueue = DispatchQueue(label: "notificationCenterList")

    init(session: Session,
         settings: LocalSettingsStore,
         userSettings: UserSettings,
         resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
         premiumService: PremiumServiceProtocol,
         lockService: LockServiceProtocol,
         teamspaceService: TeamSpacesService,
         abtestService: ABTestingServiceProtocol,
         keychainService: AuthenticationKeychainServiceProtocol,
         featureService: FeatureServiceProtocol,
         notificationCenterService: NotificationCenterServiceProtocol,
         identityDashboardService: IdentityDashboardServiceProtocol,
         authenticatorNotificationFactory: @escaping (DashlaneNotification) -> AuthenticatorNotificationRowViewModel,
         resetMasterPasswordNotificationFactory: @escaping (DashlaneNotification) -> ResetMasterPasswordNotificationRowViewModel,
         trialPeriodNotificationFactory: @escaping (DashlaneNotification) -> TrialPeriodNotificationRowViewModel,
         secureLockNotificationFactory: @escaping (DashlaneNotification) -> SecureLockNotificationRowViewModel,
         sharingItemNotificationFactory: @escaping (DashlaneNotification) -> SharingRequestNotificationRowViewModel,
         securityAlertNotificationFactory: @escaping (DashlaneNotification) -> SecurityAlertNotificationRowViewModel) {
        self.trialPeriodNotificationFactory = trialPeriodNotificationFactory
        self.resetMasterPasswordNotificationFactory = resetMasterPasswordNotificationFactory
        self.sharingItemNotificationFactory = sharingItemNotificationFactory
        self.securityAlertNotificationFactory = securityAlertNotificationFactory
        self.secureLockNotificationFactory = secureLockNotificationFactory
        self.notificationCenterService = notificationCenterService
        self.authenticatorNotificationFactory = authenticatorNotificationFactory
        setupSections()
    }

    func setupSections() {
        notificationCenterService
            .$notifications
            .receive(on: computingQueue)
            .map { notifications -> [NotificationDataSection] in
                let displayedNotifications = notifications
                    .filter(\.state.isDisplayable)
                    .sorted { $0.creationDate > $1.creationDate }
                return Dictionary(grouping: displayedNotifications, by: \.category)
                    .sorted { $0.key < $1.key }
                    .map(NotificationDataSection.init)
            }
            .receive(on: RunLoop.main)
            .assign(to: &$sections)
    }

    func sectionViewModel(section: NotificationDataSection) -> NotificationSectionViewModel {
        return .init(notificationCenterService: notificationCenterService,
                     dataSection: section,
                     authenticatorNotificationFactory: authenticatorNotificationFactory,
                     resetMasterPasswordNotificationFactory: resetMasterPasswordNotificationFactory,
                     trialPeriodNotificationFactory: trialPeriodNotificationFactory,
                     secureLockNotificationFactory: secureLockNotificationFactory,
                     sharingItemNotificationFactory: sharingItemNotificationFactory,
                     securityAlertNotificationFactory: securityAlertNotificationFactory) {
            let model = self.categoryListViewModel(section: section)
            self.steps.append(.category(model))
        }
    }

    func categoryListViewModel(section: NotificationDataSection) -> NotificationsCategoryListViewModel {
        return .init(section: section,
                     notificationCenterService: notificationCenterService,
                     authenticatorNotificationFactory: authenticatorNotificationFactory,
                     resetMasterPasswordNotificationFactory: resetMasterPasswordNotificationFactory,
                     trialPeriodNotificationFactory: trialPeriodNotificationFactory,
                     secureLockNotificationFactory: secureLockNotificationFactory,
                     sharingItemNotificationFactory: sharingItemNotificationFactory,
                     securityAlertNotificationFactory: securityAlertNotificationFactory)
    }

    func display(category: NotificationCategory) {
        let dataSection = sections.first { dataSection in
            dataSection.category == .securityAlerts
        }
        guard let dataSection = dataSection else { return }
        let model = categoryListViewModel(section: dataSection)
        self.steps.append(.category(model))
    }
}

@MainActor
extension NotificationsListViewModel {
    static var mock: NotificationsListViewModel {
        NotificationsListViewModel(session: Session.mock,
                                   settings: .mock(),
                                   userSettings: UserSettings.mock,
                                   resetMasterPasswordService: ResetMasterPasswordService.mock,
                                   premiumService: PremiumServiceMock(),
                                   lockService: LockServiceMock(),
                                   teamspaceService: MockServicesContainer().teamSpacesService,
                                   abtestService: ABTestingServiceMock.mock,
                                   keychainService: .fake,
                                   featureService: .mock(),
                                   notificationCenterService: NotificationCenterService.mock,
                                   identityDashboardService: IdentityDashboardService.mock,
                                   authenticatorNotificationFactory: {_ in .mock},
                                   resetMasterPasswordNotificationFactory: {_ in .mock},
                                   trialPeriodNotificationFactory: {_ in .mock},
                                   secureLockNotificationFactory: {_ in .mock},
                                   sharingItemNotificationFactory: {_ in .mock},
                                   securityAlertNotificationFactory: {_ in .mock})
    }
}
