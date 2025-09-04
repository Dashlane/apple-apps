import Foundation

public struct LocalLoginConfiguration: Hashable, Sendable {
  public let session: Session
  public let shouldResetMP: Bool
  public let shouldRefreshKeychainMasterKey: Bool
  public let isFirstLogin: Bool
  public let newMasterPassword: String?
  public let authTicket: AuthTicket?
  public let authenticationMode: AuthenticationMode?
  public let verificationMode: LocalLoginVerificationMode
  public let isBackupCode: Bool
  public let isRecoveryLogin: Bool

  public init(
    session: Session,
    shouldResetMP: Bool = false,
    shouldRefreshKeychainMasterKey: Bool = true,
    isFirstLogin: Bool = false,
    isRecoveryLogin: Bool = false,
    newMasterPassword: String? = nil,
    authTicket: AuthTicket? = nil,
    authenticationMode: AuthenticationMode?,
    verificationMode: LocalLoginVerificationMode = .none,
    isBackupCode: Bool = false
  ) {
    self.session = session
    self.shouldResetMP = shouldResetMP
    self.shouldRefreshKeychainMasterKey = shouldRefreshKeychainMasterKey
    self.isFirstLogin = isFirstLogin
    self.newMasterPassword = newMasterPassword
    self.authTicket = authTicket
    self.authenticationMode = authenticationMode
    self.verificationMode = verificationMode
    self.isBackupCode = isBackupCode
    self.isRecoveryLogin = isRecoveryLogin
  }
}
