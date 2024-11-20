import CoreCrypto
import CoreSession
import DashTypes
import DashlaneAPI
import Foundation

@MainActor
public final class AccountRecoveryKeyLoginViewModel: ObservableObject, LoginKitServicesInjecting {

  var recoveryKey: String = ""

  let accountType: CoreSession.AccountType

  private let generateMasterKey: @MainActor (_ recoveryKey: String) async -> Void

  public init(
    accountType: CoreSession.AccountType,
    generateMasterKey: @escaping @MainActor (_ recoveryKey: String) async -> Void
  ) {
    self.accountType = accountType
    self.generateMasterKey = generateMasterKey
  }

  fileprivate init(
    recoveryKey: String,
    accountType: CoreSession.AccountType,
    generateMasterKey: @escaping @MainActor (_ recoveryKey: String) async -> Void
  ) {
    self.recoveryKey = recoveryKey
    self.accountType = accountType
    self.generateMasterKey = generateMasterKey
  }

  func validate() async {
    await generateMasterKey(recoveryKey)
  }
}

extension AccountRecoveryKeyLoginViewModel {
  static func mock(recoveryKey: String = "") -> AccountRecoveryKeyLoginViewModel {
    AccountRecoveryKeyLoginViewModel(
      recoveryKey: recoveryKey,
      accountType: .invisibleMasterPassword,
      generateMasterKey: { _ in }
    )
  }
}
