import Combine
import CoreLocalization
import CoreSession
import CoreSettings
import CoreTypes
import Foundation
import LocalAuthentication
import UserTrackingFoundation

@MainActor
public class AccessControlViewModel: ObservableObject {
  public indirect enum AccessMode {
    case masterPassword(String)
    case biometry(fallbackMode: AccessMode?)
    case pin(SecureLockMode.PinCodeLock, fallbackMode: AccessMode?)

    var isPin: Bool {
      switch self {
      case .pin:
        return true
      default:
        return false
      }
    }
  }

  @Published
  var mode: AccessMode

  let reason: AccessControlReason
  let userSettings: UserSettings

  let completion: AccessControlCompletion

  public init(
    mode: AccessControlViewModel.AccessMode,
    reason: AccessControlReason,
    userSettings: UserSettings,
    completion: @escaping AccessControlCompletion
  ) {
    self.mode = mode
    self.reason = reason
    self.userSettings = userSettings
    self.completion = completion
  }

  public convenience init(
    request: AccessControlService.UserVerificationRequest, userSettings: UserSettings
  ) {
    self.init(
      mode: request.initialAccessMode, reason: request.reason, userSettings: userSettings,
      completion: request.completion)
  }

  func makePincodeViewModel(lock: SecureLockMode.PinCodeLock, fallbackMode: AccessMode?)
    -> PinCodeAccessLockViewModel
  {
    PinCodeAccessLockViewModel(
      reason: reason,
      lock: lock,
      userSettings: userSettings
    ) { [weak self] result in
      guard let self = self else { return }

      switch result {
      case .success:
        completion(.success(Void()))
      case let .failure(error):
        switch error {
        case .refused where fallbackMode != nil:
          mode = fallbackMode!
        default:
          completion(.failure(.refused))
        }
      }
    }
  }

  func makeMasterPasswordViewModel(masterPassword: String) -> MasterPasswordAccessLockViewModel {
    MasterPasswordAccessLockViewModel(
      reason: reason,
      masterPassword: masterPassword,
      completion: completion)
  }

  func validateBiometry(fallbackMode: AccessMode?) {
    let context = LAContext()
    context.localizedFallbackTitle = fallbackMode?.isPin == true ? CoreL10n.enterPasscode : nil
    context.evaluatePolicy(
      LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason.promptMessage
    ) { (success, _) in
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        if success {
          completion(.success(Void()))
        } else if let fallbackMode {
          mode = fallbackMode
        } else {
          completion(.failure(.refused))
        }
      }
    }
  }
}

extension AccessControlViewModel {
  static func mock(mode: AccessControlViewModel.AccessMode) -> AccessControlViewModel {
    AccessControlViewModel(
      mode: mode,
      reason: .unlockItem,
      userSettings: .mock
    ) { _ in

    }
  }
}
