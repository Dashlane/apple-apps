import DashTypes
import DashlaneAPI
import Foundation

public struct SSOAuthenticationInfo: Hashable {
  public let login: Login
  public let serviceProviderUrl: URL
  public let isNitroProvider: Bool
  public let migration: AuthenticationMigration?

  public init(
    login: Login,
    serviceProviderUrl: URL,
    isNitroProvider: Bool,
    migration: AuthenticationMigration?
  ) {
    self.login = login
    self.serviceProviderUrl = serviceProviderUrl
    self.isNitroProvider = isNitroProvider
    self.migration = migration
  }
}

extension SSOAuthenticationInfo {
  public static func mock(isNitroProvider: Bool = false) -> SSOAuthenticationInfo {
    SSOAuthenticationInfo(
      login: Login("_"), serviceProviderUrl: URL(string: "_")!, isNitroProvider: isNitroProvider,
      migration: nil)
  }
}
