import Combine
import CoreKeychain
import CoreSession
import CoreSettings
import DashTypes
import Foundation
import LoginKit
import NotificationKit

@MainActor
class ResetMasterPasswordNotificationRowViewModel: SessionServicesInjecting {
  let notification: DashlaneNotification
  let resetMasterPasswordIntroViewModelFactory: ResetMasterPasswordIntroViewModel.Factory

  init(
    notification: DashlaneNotification,
    resetMasterPasswordIntroViewModelFactory: ResetMasterPasswordIntroViewModel.Factory
  ) {
    self.notification = notification
    self.resetMasterPasswordIntroViewModelFactory = resetMasterPasswordIntroViewModelFactory
  }

}

@MainActor
extension ResetMasterPasswordNotificationRowViewModel {
  static var mock: ResetMasterPasswordNotificationRowViewModel {
    .init(
      notification: ResetMasterPasswordNotification(
        state: .seen,
        creationDate: Date(),
        notificationActionHandler: NotificationSettings.mock
      ),
      resetMasterPasswordIntroViewModelFactory: .init({ .mock })
    )
  }
}
