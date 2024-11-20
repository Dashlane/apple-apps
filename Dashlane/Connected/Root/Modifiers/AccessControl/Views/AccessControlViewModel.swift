import Combine
import CoreLocalization
import CoreSession
import CoreUserTracking
import DashTypes
import Foundation
import LocalAuthentication
import LoginKit

@MainActor
class AccessControlViewModel: ObservableObject, SessionServicesInjecting {
  indirect enum AccessMode {
    case masterPassword(String)
    case biometry(fallbackMode: AccessMode?)
    case pin(SecureLockMode.PinCodeLock)

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

  let completion: AccessControlCompletion

  init(
    mode: AccessControlViewModel.AccessMode,
    reason: AccessControlReason,
    completion: @escaping AccessControlCompletion
  ) {
    self.reason = reason
    self.completion = completion
    self.mode = mode
  }

  convenience init(request: AccessControlService.UserVerificationRequest) {
    self.init(
      mode: request.initialAccessMode, reason: request.reason, completion: request.completion)
  }

  func makePincodeViewModel(lock: SecureLockMode.PinCodeLock) -> PinCodeAccessLockViewModel {
    PinCodeAccessLockViewModel(
      reason: reason,
      lock: lock,
      completion: completion)
  }

  func makeMasterPasswordViewModel(masterPassword: String) -> MasterPasswordAccessLockViewModel {
    MasterPasswordAccessLockViewModel(
      reason: reason,
      masterPassword: masterPassword,
      completion: completion)
  }

  func validateBiometry(fallbackMode: AccessMode?) {
    let context = LAContext()
    context.localizedFallbackTitle =
      fallbackMode?.isPin == true ? CoreLocalization.L10n.Core.enterPasscode : nil
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
      reason: .unlockItem
    ) { _ in

    }
  }
}
