import Combine
import CoreSession
import CoreSettings
import CoreTypes
import Foundation

public class AccessControlService: AccessControlHandler, @unchecked Sendable {
  public struct UserVerificationRequest: Identifiable {
    public let id = UUID()
    public let initialAccessMode: AccessControlViewModel.AccessMode
    public let reason: AccessControlReason
    public let completion: AccessControlCompletion
  }

  @Published
  var userVerificationRequest: UserVerificationRequest?

  private let session: Session
  private let secureLockModeProvider: SecureLockProviderProtocol
  private let pincodeAttempts: PinCodeAttempts

  public init(
    session: Session, secureLockModeProvider: SecureLockProviderProtocol, userSettings: UserSettings
  ) {
    self.session = session
    self.secureLockModeProvider = secureLockModeProvider
    self.pincodeAttempts = PinCodeAttempts(internalStore: userSettings.internalStore)
  }

  public func requestAccess(
    for reason: CoreTypes.AccessControlReason, completion: @escaping AccessControlCompletion
  ) {
    let secureLockMode = secureLockModeProvider.secureLockMode()

    let defaultUserAccessMode: AccessControlViewModel.AccessMode? =
      if let userPassword = session.authenticationMethod.userMasterPassword {
        .masterPassword(userPassword)
      } else if session.authenticationMethod.isInvisibleMasterPassword,
        case .pincode(let lock) = secureLockMode
      {
        .pin(lock, fallbackMode: nil)
      } else {
        nil
      }

    var userAccessMode: AccessControlViewModel.AccessMode?

    if case .authenticationSetup = reason {
      userAccessMode = defaultUserAccessMode
    } else {
      userAccessMode =
        switch secureLockMode {
        case .biometry:
          .biometry(fallbackMode: defaultUserAccessMode)
        case .pincode where pincodeAttempts.tooManyAttempts:
          defaultUserAccessMode
        case .pincode(let lock):
          .pin(
            lock,
            fallbackMode: session.authenticationMethod.userMasterPassword != nil
              ? defaultUserAccessMode : nil)
        case .biometryAndPincode(_, let lock):
          .biometry(fallbackMode: .pin(lock, fallbackMode: defaultUserAccessMode))
        case .masterKey, .rememberMasterPassword:
          defaultUserAccessMode
        }
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
