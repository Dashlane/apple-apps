import Foundation

extension UserDeviceAPIClient.Accountrecovery {
  public struct GetAuthenticatedEncryptedVaultKey: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/accountrecovery/GetAuthenticatedEncryptedVaultKey"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(timeout: TimeInterval? = nil) async throws -> Response {
      let body = Body()
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var getAuthenticatedEncryptedVaultKey: GetAuthenticatedEncryptedVaultKey {
    GetAuthenticatedEncryptedVaultKey(api: api)
  }
}

extension UserDeviceAPIClient.Accountrecovery.GetAuthenticatedEncryptedVaultKey {
  public typealias Body = Empty?
}

extension UserDeviceAPIClient.Accountrecovery.GetAuthenticatedEncryptedVaultKey {
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case encryptedVaultKey = "encryptedVaultKey"
    }

    public let encryptedVaultKey: String

    public init(encryptedVaultKey: String) {
      self.encryptedVaultKey = encryptedVaultKey
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(encryptedVaultKey, forKey: .encryptedVaultKey)
    }
  }
}
