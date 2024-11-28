import Foundation

public struct RegistrationData: Hashable {
  public let transferData: AccountTransferInfo
  public var pin: String?
  public var authTicket: AuthTicket
  public let isRecoveryLogin: Bool
  public var shouldEnableBiometry: Bool
  public var newMasterPassword: String?
  public let transferMethod: TransferMethod
  public let isBackupCode: Bool
  public let verificationMethod: VerificationMethod

  public init(
    transferData: AccountTransferInfo,
    pin: String? = nil,
    authTicket: AuthTicket,
    isRecoveryLogin: Bool = false,
    shouldEnableBiometry: Bool = false,
    newMasterPassword: String? = nil,
    isBackupCode: Bool = false,
    transferMethod: TransferMethod,
    verificationMethod: VerificationMethod = .emailToken
  ) {
    self.transferData = transferData
    self.pin = pin
    self.authTicket = authTicket
    self.isRecoveryLogin = isRecoveryLogin
    self.shouldEnableBiometry = shouldEnableBiometry
    self.newMasterPassword = newMasterPassword
    self.transferMethod = transferMethod
    self.isBackupCode = isBackupCode
    self.verificationMethod = verificationMethod
  }
}
