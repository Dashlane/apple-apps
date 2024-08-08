import Foundation

public struct RegistrationData: Hashable {
  public let transferData: AccountTransferInfo
  public var pin: String?
  public var authTicket: AuthTicket
  public let isRecoveryLogin: Bool
  public var shouldEnableBiometry: Bool
  public var newMasterPassword: String?
  public let transferMethod: TransferMethod

  public init(
    transferData: AccountTransferInfo,
    pin: String? = nil, authTicket: AuthTicket,
    isRecoveryLogin: Bool = false,
    shouldEnableBiometry: Bool = false,
    newMasterPassword: String? = nil,
    transferMethod: TransferMethod
  ) {
    self.transferData = transferData
    self.pin = pin
    self.authTicket = authTicket
    self.isRecoveryLogin = isRecoveryLogin
    self.shouldEnableBiometry = shouldEnableBiometry
    self.newMasterPassword = newMasterPassword
    self.transferMethod = transferMethod
  }
}
