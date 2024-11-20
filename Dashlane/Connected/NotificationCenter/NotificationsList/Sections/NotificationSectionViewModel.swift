import Foundation
import SwiftTreats

class NotificationSectionViewModel {
  let notificationCenterService: NotificationCenterServiceProtocol
  let dataSection: NotificationDataSection
  let shouldShowHeader: Bool
  let isTruncated: Bool
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

  var displayableNotifications: [DashlaneNotification] {
    isTruncated ? Array(dataSection.notifications.prefix(2)) : dataSection.notifications
  }

  init(
    notificationCenterService: NotificationCenterServiceProtocol,
    dataSection: NotificationDataSection,
    shouldShowHeader: Bool = true,
    isTruncated: Bool = true,
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
    self.trialPeriodNotificationFactory = trialPeriodNotificationFactory
    self.securityAlertNotificationFactory = securityAlertNotificationFactory
    self.resetMasterPasswordNotificationFactory = resetMasterPasswordNotificationFactory
    self.sharingItemNotificationFactory = sharingItemNotificationFactory
    self.secureLockNotificationFactory = secureLockNotificationFactory
    self.frozenAccountNotificationFactory = frozenAccountNotificationFactory
    self.isTruncated = isTruncated
    self.dataSection = dataSection
    self.shouldShowHeader = shouldShowHeader
    self.notificationCenterService = notificationCenterService
  }

  func resetMasterPasswordViewModel(_ notification: DashlaneNotification)
    -> ResetMasterPasswordNotificationRowViewModel
  {
    resetMasterPasswordNotificationFactory(notification)
  }

  func trialPeriodViewModel(_ notification: DashlaneNotification)
    -> TrialPeriodNotificationRowViewModel
  {
    trialPeriodNotificationFactory(notification)
  }

  func secureLockPasswordViewModel(_ notification: DashlaneNotification)
    -> SecureLockNotificationRowViewModel
  {
    secureLockNotificationFactory(notification)
  }

  func sharingItemViewModel(_ notification: DashlaneNotification)
    -> SharingRequestNotificationRowViewModel
  {
    sharingItemNotificationFactory(notification)
  }

  func securityAlertViewModel(_ notification: DashlaneNotification)
    -> SecurityAlertNotificationRowViewModel
  {
    securityAlertNotificationFactory(notification)
  }

  func frozenAccountViewModel(_ notification: DashlaneNotification)
    -> FrozenAccountNotificationRowViewModel
  {
    frozenAccountNotificationFactory(notification)
  }
}

@MainActor
extension NotificationSectionViewModel {
  private static let notifications: [DashlaneNotification] = [
    ResetMasterPasswordNotification(
      state: .seen,
      creationDate: Date(),
      notificationActionHandler: NotificationSettings.mock
    ),
    ResetMasterPasswordNotification(
      state: .dismissed,
      creationDate: Date(),
      notificationActionHandler: NotificationSettings.mock
    ),
    ResetMasterPasswordNotification(
      state: .unseen,
      creationDate: Date(),
      notificationActionHandler: NotificationSettings.mock
    ),
  ]

  static var mock: NotificationSectionViewModel {
    .init(
      notificationCenterService: NotificationCenterService.mock,
      dataSection: .init(category: .gettingStarted, notifications: notifications),
      resetMasterPasswordNotificationFactory: { _ in
        ResetMasterPasswordNotificationRowViewModel.mock
      },
      trialPeriodNotificationFactory: { _ in TrialPeriodNotificationRowViewModel.mock },
      secureLockNotificationFactory: { _ in SecureLockNotificationRowViewModel.mock },
      sharingItemNotificationFactory: { _ in SharingRequestNotificationRowViewModel.mock },
      securityAlertNotificationFactory: { _ in SecurityAlertNotificationRowViewModel.mock },
      frozenAccountNotificationFactory: { _ in FrozenAccountNotificationRowViewModel.mock }
    )
  }
}
