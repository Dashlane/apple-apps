import DashTypes
import Foundation
import LoginKit
import SwiftTreats

class SecureLockNotificationRowViewModel: ObservableObject, SessionServicesInjecting {
  enum SecureLockType {
    case pin(String?)
    case touchId
    case faceId
  }

  @Published
  var presentMPStoredInKeychainAlert: Bool = false

  @Published
  var choosePinCode: Bool = false

  let notification: DashlaneNotification
  let lockService: LockServiceProtocol
  var secureLockType: SecureLockType

  init(
    notification: DashlaneNotification,
    lockService: LockServiceProtocol
  ) {
    self.notification = notification
    self.lockService = lockService
    switch Device.biometryType {
    case .touchId:
      secureLockType = .touchId
    case .faceId:
      secureLockType = .faceId
    default:
      secureLockType = .pin(nil)
    }

  }

  func didTapOnEnableSecureLock() {
    switch secureLockType {
    case .touchId, .faceId:
      self.presentMPStoredInKeychainAlert = true
    default:
      self.choosePinCode = true
    }
  }

  func pinCodeViewModel() -> PinCodeSelectionViewModel {
    return PinCodeSelectionViewModel(currentPin: nil) { newPin in
      self.choosePinCode = false
      self.secureLockType = .pin(newPin)
      guard newPin != nil else { return }
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        self.presentMPStoredInKeychainAlert = true
      }
    }
  }

  func enableSecureLock() {
    switch secureLockType {
    case .pin(let code):
      guard let code = code else { return }
      try? lockService.secureLockConfigurator.enablePinCode(code)
    case .touchId, .faceId:
      try? lockService.secureLockConfigurator.enableBiometry()
    }
  }
}

extension SecureLockNotificationRowViewModel {
  static var mock: SecureLockNotificationRowViewModel {
    .init(
      notification: SecureLockNotification(
        state: .seen,
        creationDate: Date(),
        notificationActionHandler: NotificationSettings.mock
      ),
      lockService: LockServiceMock()
    )
  }
}
