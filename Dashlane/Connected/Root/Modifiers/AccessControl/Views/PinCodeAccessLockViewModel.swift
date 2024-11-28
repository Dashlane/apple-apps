import DashTypes
import Foundation
import LoginKit

@MainActor
class PinCodeAccessLockViewModel: ObservableObject {
  @Published
  var enteredPincode: String = "" {
    didSet {
      if enteredPincode.count == pinCodeLength {
        validate()
      }
    }
  }
  @Published
  var attempts: Int = 0
  @Published
  var showWrongPin: Bool = false

  var pinCodeLength: Int {
    lock.code.count
  }

  let reason: AccessControlReason

  private let lock: SecureLockMode.PinCodeLock
  private let completion: AccessControlCompletion

  init(
    reason: AccessControlReason,
    lock: SecureLockMode.PinCodeLock,
    completion: @escaping AccessControlCompletion
  ) {
    self.reason = reason
    self.lock = lock
    self.completion = completion
  }

  func cancel() {
    completion(.failure(.cancelled))
  }

  func validate() {

    guard lock.code == enteredPincode else {
      attempts += 1
      lock.attempts.addNewAttempt()

      if lock.attempts.tooManyAttempts {
        completion(.failure(.refused))
      } else {
        showWrongPin = true
      }
      return
    }

    completion(.success)
  }
}

extension PinCodeAccessLockViewModel {
  static func mock() -> PinCodeAccessLockViewModel {
    PinCodeAccessLockViewModel(
      reason: .unlockItem,
      lock: .init(code: "1234", attempts: .mock, masterKey: .masterPassword("p")),
      completion: { _ in

      })
  }
}
