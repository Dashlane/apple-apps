import Combine
import CoreSession
import DashTypes
import Foundation
import LoginKit

class AccessControlService: AccessControlHandler, @unchecked Sendable {
  struct UserVerificationRequest: Identifiable {
    let id = UUID()
    let initialAccessMode: AccessControlViewModel.AccessMode
    let reason: AccessControlReason
    let completion: AccessControlCompletion
  }

  @Published
  var userVerificationRequest: UserVerificationRequest?

  private let session: Session
  private let secureLockModeProvider: SecureLockProviderProtocol

  init(session: Session, secureLockModeProvider: SecureLockProviderProtocol) {
    self.session = session
    self.secureLockModeProvider = secureLockModeProvider
  }

  func requestAccess(
    for reason: DashTypes.AccessControlReason, completion: @escaping AccessControlCompletion
  ) {
    let secureLockMode = secureLockModeProvider.secureLockMode()

    let defaultUserAccessMode: AccessControlViewModel.AccessMode? =
      if let userPassword = session.authenticationMethod.userMasterPassword {
        .masterPassword(userPassword)
      } else {
        nil
      }

    let userAccessMode: AccessControlViewModel.AccessMode? =
      switch secureLockMode {
      case .biometry:
        .biometry(fallbackMode: defaultUserAccessMode)
      case .pincode(let lock):
        .pin(lock)
      case .biometryAndPincode(_, let lock):
        .biometry(fallbackMode: .pin(lock))
      case .masterKey, .rememberMasterPassword:
        defaultUserAccessMode
      }

    if let userAccessMode {
      userVerificationRequest = UserVerificationRequest(
        initialAccessMode: userAccessMode,
        reason: reason,
        completion: completion)
    } else {
      Task {
        await completion(.success)
      }
    }
  }
}
