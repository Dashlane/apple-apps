import Foundation

extension UserDeviceAPIClient.Accountrecovery {
  public struct RequestActivation: APIRequest {
    public static let endpoint: Endpoint = "/accountrecovery/RequestActivation"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(encryptedVaultKey: String, timeout: TimeInterval? = nil) async throws
      -> Response
    {
      let body = Body(encryptedVaultKey: encryptedVaultKey)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var requestActivation: RequestActivation {
    RequestActivation(api: api)
  }
}

extension UserDeviceAPIClient.Accountrecovery.RequestActivation {
  public struct Body: Codable, Equatable, Sendable {
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

extension UserDeviceAPIClient.Accountrecovery.RequestActivation {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case recoveryId = "recoveryId"
    }

    public let recoveryId: String

    public init(recoveryId: String) {
      self.recoveryId = recoveryId
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(recoveryId, forKey: .recoveryId)
    }
  }
}
