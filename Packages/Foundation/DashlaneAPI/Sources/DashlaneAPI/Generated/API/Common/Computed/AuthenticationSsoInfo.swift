import Foundation

public struct AuthenticationSsoInfo: Codable, Hashable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case serviceProviderUrl = "serviceProviderUrl"
    case isNitroProvider = "isNitroProvider"
    case migration = "migration"
  }

  public let serviceProviderUrl: String
  public let isNitroProvider: Bool?
  public let migration: AuthenticationMigration?

  public init(
    serviceProviderUrl: String, isNitroProvider: Bool? = nil,
    migration: AuthenticationMigration? = nil
  ) {
    self.serviceProviderUrl = serviceProviderUrl
    self.isNitroProvider = isNitroProvider
    self.migration = migration
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(serviceProviderUrl, forKey: .serviceProviderUrl)
    try container.encodeIfPresent(isNitroProvider, forKey: .isNitroProvider)
    try container.encodeIfPresent(migration, forKey: .migration)
  }
}
