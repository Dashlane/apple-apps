import CoreTypes
import Foundation

@MainActor
class MasterPasswordAccessLockViewModel: ObservableObject {
  @Published
  var enteredPassword: String = ""

  @Published
  var showWrongPassword: Bool = false

  let reason: AccessControlReason

  private let masterPassword: String
  private let completion: AccessControlCompletion

  init(
    reason: AccessControlReason,
    masterPassword: String,
    completion: @escaping AccessControlCompletion
  ) {
    self.reason = reason
    self.masterPassword = masterPassword
    self.completion = completion
  }

  func cancel() {
    completion(.failure(.cancelled))
  }

  func validate() {
    guard enteredPassword == masterPassword else {
      showWrongPassword = true
      return
    }
    completion(.success)
  }
}

extension MasterPasswordAccessLockViewModel {
  static func mock() -> MasterPasswordAccessLockViewModel {
    MasterPasswordAccessLockViewModel(
      reason: .changeContactEmail,
      masterPassword: "password"
    ) { _ in

    }
  }
}
