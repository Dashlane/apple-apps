import CoreSession
import CoreSettings
import CoreTypes
import Foundation

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

  @Published
  var showTooManyAttempts: Bool = false

  let reason: AccessControlReason

  private let lock: SecureLockMode.PinCodeLock
  private let pinCodeAttempts: PinCodeAttempts
  private let completion: AccessControlCompletion

  init(
    reason: AccessControlReason,
    lock: SecureLockMode.PinCodeLock,
    userSettings: UserSettings,
    completion: @escaping AccessControlCompletion
  ) {
    self.reason = reason
    self.lock = lock
    self.completion = completion
    self.pinCodeAttempts = PinCodeAttempts(internalStore: userSettings.internalStore)
    pinCodeAttempts.countPublisher.assign(to: &$attempts)
    if pinCodeAttempts.tooManyAttempts {
      showTooManyAttempts = true
    }
  }

  func cancel() {
    completion(.failure(.cancelled))
  }

  func validate() {

    guard lock.code == enteredPincode else {
      attempts += 1
      pinCodeAttempts.addNewAttempt()

      if pinCodeAttempts.tooManyAttempts {
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
      lock: .init(
        code: "1234",
        masterKey: .masterPassword("p")),
      userSettings: .mock,
      completion: { _ in

      })
  }
}
