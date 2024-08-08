import Foundation

extension AppAPIClient.Accountrecovery {
  public struct GetEncryptedVaultKey: APIRequest {
    public static let endpoint: Endpoint = "/accountrecovery/GetEncryptedVaultKey"

    public let api: AppAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(login: String, authTicket: String, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      let body = Body(login: login, authTicket: authTicket)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var getEncryptedVaultKey: GetEncryptedVaultKey {
    GetEncryptedVaultKey(api: api)
  }
}

extension AppAPIClient.Accountrecovery.GetEncryptedVaultKey {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case login = "login"
      case authTicket = "authTicket"
    }

    public let login: String
    public let authTicket: String

    public init(login: String, authTicket: String) {
      self.login = login
      self.authTicket = authTicket
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(login, forKey: .login)
      try container.encode(authTicket, forKey: .authTicket)
    }
  }
}

extension AppAPIClient.Accountrecovery.GetEncryptedVaultKey {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case encryptedVaultKey = "encryptedVaultKey"
      case recoveryId = "recoveryId"
    }

    public let encryptedVaultKey: String
    public let recoveryId: String

    public init(encryptedVaultKey: String, recoveryId: String) {
      self.encryptedVaultKey = encryptedVaultKey
      self.recoveryId = recoveryId
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(encryptedVaultKey, forKey: .encryptedVaultKey)
      try container.encode(recoveryId, forKey: .recoveryId)
    }
  }
}
