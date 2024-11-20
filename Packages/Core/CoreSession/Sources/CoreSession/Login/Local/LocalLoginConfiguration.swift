import Foundation

public struct LocalLoginConfiguration: Hashable {
  public let session: Session?
  public let shouldResetMP: Bool
  public let shouldRefreshKeychainMasterKey: Bool
  public let isRecoveryLogin: Bool
  public let isFirstLogin: Bool
  public let newMasterPassword: String?
  public init(
    session: Session?,
    shouldResetMP: Bool = false,
    shouldRefreshKeychainMasterKey: Bool = true,
    isRecoveryLogin: Bool = false,
    isFirstLogin: Bool = false,
    newMasterPassword: String? = nil
  ) {
    self.session = session
    self.shouldResetMP = shouldResetMP
    self.shouldRefreshKeychainMasterKey = shouldRefreshKeychainMasterKey
    self.isRecoveryLogin = isRecoveryLogin
    self.isFirstLogin = isFirstLogin
    self.newMasterPassword = newMasterPassword
  }
}
