import Foundation

extension UserDeviceAPIClient.Accountrecovery {
  public struct Deactivate: APIRequest {
    public static let endpoint: Endpoint = "/accountrecovery/Deactivate"

    public let api: UserDeviceAPIClient

    @discardableResult public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    @discardableResult public func callAsFunction(reason: Body.Reason, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      let body = Body(reason: reason)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var deactivate: Deactivate {
    Deactivate(api: api)
  }
}

extension UserDeviceAPIClient.Accountrecovery.Deactivate {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case reason = "reason"
    }

    public enum Reason: String, Sendable, Equatable, CaseIterable, Codable {
      case settings = "SETTINGS"
      case keyUsed = "KEY_USED"
      case vaultKeyChange = "VAULT_KEY_CHANGE"
      case undecodable
      public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Self(rawValue: rawValue) ?? .undecodable
      }
    }

    public let reason: Reason

    public init(reason: Reason) {
      self.reason = reason
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(reason, forKey: .reason)
    }
  }
}

extension UserDeviceAPIClient.Accountrecovery.Deactivate {
  public typealias Response = Empty?
}
