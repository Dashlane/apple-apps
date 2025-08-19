import CoreTypes
import Foundation

public struct AccountRecoveryInfo: Identifiable, Hashable, Sendable {
  public var id: String {
    return login.email
  }
  public let login: Login
  public let isEnabled: Bool
  public let accountType: CoreSession.AccountType

  public init(login: Login, isEnabled: Bool, accountType: CoreSession.AccountType) {
    self.login = login
    self.isEnabled = isEnabled
    self.accountType = accountType
  }
}
