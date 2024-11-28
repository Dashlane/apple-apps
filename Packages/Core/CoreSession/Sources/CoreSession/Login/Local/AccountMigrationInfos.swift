import Foundation

public struct AccountMigrationInfos: Hashable {
  public let session: Session
  public let type: SSOMigrationType
  public let ssoAuthenticationInfo: SSOAuthenticationInfo
  public let authTicket: AuthTicket?
}
