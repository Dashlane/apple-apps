import SwiftUI
import UserTrackingFoundation

class NotificationsCategoryListViewModel {
  let section: NotificationDataSection
  let notificationCenterService: NotificationCenterServiceProtocol

  private let resetMasterPasswordNotificationFactory:
    @MainActor (DashlaneNotification) -> ResetMasterPasswordNotificationRowViewModel
  private let trialPeriodNotificationFactory:
    (DashlaneNotification) -> TrialPeriodNotificationRowViewModel
  private let secureLockNotificationFactory:
    (DashlaneNotification) -> SecureLockNotificationRowViewModel
  private let sharingItemNotificationFactory:
    (DashlaneNotification) ->
      SharingRequestNotificationRowViewModel
  private let securityAlertNotificationFactory:
    (DashlaneNotification) -> SecurityAlertNotificationRowViewModel
  private let frozenAccountNotificationFactory:
    (DashlaneNotification) -> FrozenAccountNotificationRowViewModel

  init(
    section: NotificationDataSection,
    notificationCenterService: NotificationCenterServiceProtocol,
    resetMasterPasswordNotificationFactory: @MainActor @escaping (DashlaneNotification) ->
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
    self.section = section
    self.notificationCenterService = notificationCenterService
    self.trialPeriodNotificationFactory = trialPeriodNotificationFactory
    self.resetMasterPasswordNotificationFactory = resetMasterPasswordNotificationFactory
    self.secureLockNotificationFactory = secureLockNotificationFactory
    self.sharingItemNotificationFactory = sharingItemNotificationFactory
    self.securityAlertNotificationFactory = securityAlertNotificationFactory
    self.frozenAccountNotificationFactory = frozenAccountNotificationFactory
  }

  func sectionViewModel() -> NotificationSectionViewModel {
    return .init(
      notificationCenterService: notificationCenterService,
      dataSection: section,
      shouldShowHeader: false,
      isTruncated: false,
      resetMasterPasswordNotificationFactory: resetMasterPasswordNotificationFactory,
      trialPeriodNotificationFactory: trialPeriodNotificationFactory,
      secureLockNotificationFactory: secureLockNotificationFactory,
      sharingItemNotificationFactory: sharingItemNotificationFactory,
      securityAlertNotificationFactory: securityAlertNotificationFactory,
      frozenAccountNotificationFactory: frozenAccountNotificationFactory
    )
  }
}

struct NotificationsCategoryListView: View {
  let model: NotificationsCategoryListViewModel

  var body: some View {
    list
      .reportPageAppearance(model.section.category.page)
  }

  var list: some View {
    List {
      NotificationSectionView(model: model.sectionViewModel()) {

      }
    }
    .listStyle(.ds.insetGrouped)
    .navigationTitle(model.section.category.sectionTitle)
    .navigationBarTitleDisplayMode(.inline)
  }
}

extension NotificationCategory {
  var sectionTitle: String {
    switch self {
    case .securityAlerts:
      return L10n.Localizable.notificationCenterSectionTitleSecurityAlert
    case .sharing:
      return L10n.Localizable.notificationCenterSectionTitleSharing
    case .gettingStarted:
      return L10n.Localizable.notificationCenterSectionTitleGettingStarted
    case .yourAccount:
      return L10n.Localizable.notificationCenterSectionTitleYourAccount
    case .whatIsNew:
      return L10n.Localizable.notificationCenterSectionTitleWhatIsNew
    }
  }
}

extension NotificationCategory {
  var page: Page {
    switch self {
    case .securityAlerts:
      return .notificationSecurityList
    case .sharing:
      return .notificationSharingList
    case .gettingStarted:
      return .notificationGettingStartedList
    case .yourAccount:
      return .notificationYourAccountList
    case .whatIsNew:
      return .notificationNewList
    }
  }
}

struct NotificationsCategoryListView_Previews: PreviewProvider {
  static let notification = ResetMasterPasswordNotification(
    state: .seen,
    creationDate: Date(),
    notificationActionHandler: NotificationSettings.mock
  )

  static let notifications: [DashlaneNotification] = [
    notification,
    notification,
    notification,
    notification,
  ]

  static let dataSection: NotificationDataSection = .init(
    category: .gettingStarted, notifications: notifications)

  static var previews: some View {
    NotificationsCategoryListView(
      model: .init(
        section: dataSection,
        notificationCenterService: NotificationCenterService.mock,
        resetMasterPasswordNotificationFactory: { _ in .mock },
        trialPeriodNotificationFactory: { _ in .mock },
        secureLockNotificationFactory: { _ in .mock },
        sharingItemNotificationFactory: { _ in .mock },
        securityAlertNotificationFactory: { _ in .mock },
        frozenAccountNotificationFactory: { _ in .mock }
      )
    )
  }
}
