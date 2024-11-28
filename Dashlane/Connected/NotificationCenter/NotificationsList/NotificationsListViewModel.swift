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

class NotificationsListViewModel: ObservableObject, SessionServicesInjecting {
  @Published
  var sections: [NotificationDataSection] = []

  private let notificationCenterService: NotificationCenterServiceProtocol
  private let resetMasterPasswordNotificationFactory:
    (DashlaneNotification) -> ResetMasterPasswordNotificationRowViewModel
  private let trialPeriodNotificationFactory:
    (DashlaneNotification) -> TrialPeriodNotificationRowViewModel
  private let secureLockNotificationFactory:
    (DashlaneNotification) -> SecureLockNotificationRowViewModel
  private let sharingItemNotificationFactory:
    (DashlaneNotification) -> SharingRequestNotificationRowViewModel
  private let securityAlertNotificationFactory:
    (DashlaneNotification) -> SecurityAlertNotificationRowViewModel
  private let frozenAccountNotificationFactory:
    (DashlaneNotification) -> FrozenAccountNotificationRowViewModel
  private let computingQueue = DispatchQueue(label: "notificationCenterList")
  let notificationCategoryDeeplink: AnyPublisher<NotificationCategory, Never>
  let unresolvedAlertViewModelFactory: UnresolvedAlertViewModel.Factory
  let deepLinkPublisher: AnyPublisher<DeepLink, Never>

  init(
    session: Session,
    settings: LocalSettingsStore,
    deeplinkService: DeepLinkingServiceProtocol,
    userSettings: UserSettings,
    resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
    lockService: LockServiceProtocol,
    userSpacesService: UserSpacesService,
    abtestService: ABTestingServiceProtocol,
    keychainService: AuthenticationKeychainServiceProtocol,
    featureService: FeatureServiceProtocol,
    notificationCenterService: NotificationCenterServiceProtocol,
    identityDashboardService: IdentityDashboardServiceProtocol,
    deepLinkService: DeepLinkingServiceProtocol,
    unresolvedAlertViewModelFactory: UnresolvedAlertViewModel.Factory,
    resetMasterPasswordNotificationFactory: @escaping (DashlaneNotification) ->
      ResetMasterPasswordNotificationRowViewModel,
    trialPeriodNotificationFactory: @escaping (DashlaneNotification) ->
      TrialPeriodNotificationRowViewModel,
    secureLockNotificationFactory: @escaping (DashlaneNotification) ->
      SecureLockNotificationRowViewModel,
    sharingItemNotificationFactory: @escaping (DashlaneNotification) ->
      SharingRequestNotificationRowViewModel,
    securityAlertNotificationFactory: @escaping (DashlaneNotification) ->
      SecurityAlertNotificationRowViewModel,
    frozenAccountNotificationFactory: @escaping (DashlaneNotification) ->
      FrozenAccountNotificationRowViewModel
  ) {
    self.notificationCategoryDeeplink = deeplinkService.notificationsDeeplinkPublisher()
    self.trialPeriodNotificationFactory = trialPeriodNotificationFactory
    self.resetMasterPasswordNotificationFactory = resetMasterPasswordNotificationFactory
    self.sharingItemNotificationFactory = sharingItemNotificationFactory
    self.securityAlertNotificationFactory = securityAlertNotificationFactory
    self.secureLockNotificationFactory = secureLockNotificationFactory
    self.frozenAccountNotificationFactory = frozenAccountNotificationFactory
    self.notificationCenterService = notificationCenterService
    self.unresolvedAlertViewModelFactory = unresolvedAlertViewModelFactory
    self.deepLinkPublisher = deepLinkService.deepLinkPublisher
    setupSections()
  }

  func setupSections() {
    notificationCenterService
      .$notifications
      .receive(on: computingQueue)
      .map { notifications -> [NotificationDataSection] in
        let displayedNotifications =
          notifications
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
    .init(
      notificationCenterService: notificationCenterService,
      dataSection: section,
      resetMasterPasswordNotificationFactory: resetMasterPasswordNotificationFactory,
      trialPeriodNotificationFactory: trialPeriodNotificationFactory,
      secureLockNotificationFactory: secureLockNotificationFactory,
      sharingItemNotificationFactory: sharingItemNotificationFactory,
      securityAlertNotificationFactory: securityAlertNotificationFactory,
      frozenAccountNotificationFactory: frozenAccountNotificationFactory
    )
  }

  func categoryListViewModel(section: NotificationDataSection) -> NotificationsCategoryListViewModel
  {
    .init(
      section: section,
      notificationCenterService: notificationCenterService,
      resetMasterPasswordNotificationFactory: resetMasterPasswordNotificationFactory,
      trialPeriodNotificationFactory: trialPeriodNotificationFactory,
      secureLockNotificationFactory: secureLockNotificationFactory,
      sharingItemNotificationFactory: sharingItemNotificationFactory,
      securityAlertNotificationFactory: securityAlertNotificationFactory,
      frozenAccountNotificationFactory: frozenAccountNotificationFactory
    )
  }

  func dataSection(for category: NotificationCategory) -> NotificationDataSection? {
    sections.first { dataSection in
      dataSection.category == .securityAlerts
    }
  }
}

@MainActor
extension NotificationsListViewModel {
  static var mock: NotificationsListViewModel {
    NotificationsListViewModel(
      session: Session.mock,
      settings: .mock(),
      deeplinkService: DeepLinkingService.fakeService,
      userSettings: UserSettings.mock,
      resetMasterPasswordService: ResetMasterPasswordService.mock,
      lockService: LockServiceMock(),
      userSpacesService: MockServicesContainer().userSpacesService,
      abtestService: ABTestingServiceMock.mock,
      keychainService: .fake,
      featureService: .mock(),
      notificationCenterService: NotificationCenterService.mock,
      identityDashboardService: IdentityDashboardService.mock,
      deepLinkService: DeepLinkingService.fakeService,
      unresolvedAlertViewModelFactory: .init { .mock },
      resetMasterPasswordNotificationFactory: { _ in .mock },
      trialPeriodNotificationFactory: { _ in .mock },
      secureLockNotificationFactory: { _ in .mock },
      sharingItemNotificationFactory: { _ in .mock },
      securityAlertNotificationFactory: { _ in .mock },
      frozenAccountNotificationFactory: { _ in .mock }
    )
  }
}
