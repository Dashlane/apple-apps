import CoreCrypto
import CoreSession
import DashTypes
import DashlaneAPI
import Foundation

@MainActor
public final class AccountRecoveryKeyLoginViewModel: ObservableObject, LoginKitServicesInjecting {

  @Published var showNoMatchError = false

  var recoveryKey: String = "" {
    didSet {
      showNoMatchError = false
    }
  }

  let accountType: CoreSession.AccountType

  private let generateMasterKey: @MainActor (_ recoveryKey: String) async throws -> Void

  public init(
    accountType: CoreSession.AccountType,
    generateMasterKey: @escaping @MainActor (_ recoveryKey: String) async throws -> Void
  ) {
    self.accountType = accountType
    self.generateMasterKey = generateMasterKey
  }

  fileprivate init(
    recoveryKey: String,
    showNoMatchError: Bool,
    accountType: CoreSession.AccountType,
    generateMasterKey: @escaping @MainActor (_ recoveryKey: String) async throws -> Void
  ) {
    self.recoveryKey = recoveryKey
    self.showNoMatchError = showNoMatchError
    self.accountType = accountType
    self.generateMasterKey = generateMasterKey
  }

  func validate() async {
    do {
      try await generateMasterKey(recoveryKey)
    } catch {
      showNoMatchError = true
    }
  }
}

extension AccountRecoveryKeyLoginViewModel {
  static func mock(recoveryKey: String = "", showNoMatchError: Bool = false)
    -> AccountRecoveryKeyLoginViewModel
  {
    AccountRecoveryKeyLoginViewModel(
      recoveryKey: recoveryKey,
      showNoMatchError: showNoMatchError,
      accountType: .invisibleMasterPassword,
      generateMasterKey: { _ in }
    )
  }
}
