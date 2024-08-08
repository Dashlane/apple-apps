import Foundation

extension UserDeviceAPIClient.Authentication {
  public struct Get2FAStatus: APIRequest {
    public static let endpoint: Endpoint = "/authentication/Get2FAStatus"

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
  public var get2FAStatus: Get2FAStatus {
    Get2FAStatus(api: api)
  }
}

extension UserDeviceAPIClient.Authentication.Get2FAStatus {
  public typealias Body = Empty?
}

extension UserDeviceAPIClient.Authentication.Get2FAStatus {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case type = "type"
      case lastUpdateDateUnix = "lastUpdateDateUnix"
      case recoveryPhone = "recoveryPhone"
      case isDuoEnabled = "isDuoEnabled"
      case hasU2FKeys = "hasU2FKeys"
      case ssoInfo = "ssoInfo"
    }

    public let type: Authentication2FAStatusType
    public let lastUpdateDateUnix: Int?
    public let recoveryPhone: String?
    public let isDuoEnabled: Bool
    public let hasU2FKeys: Bool
    public let ssoInfo: AuthenticationSsoInfo?

    public init(
      type: Authentication2FAStatusType, lastUpdateDateUnix: Int?, recoveryPhone: String?,
      isDuoEnabled: Bool, hasU2FKeys: Bool, ssoInfo: AuthenticationSsoInfo? = nil
    ) {
      self.type = type
      self.lastUpdateDateUnix = lastUpdateDateUnix
      self.recoveryPhone = recoveryPhone
      self.isDuoEnabled = isDuoEnabled
      self.hasU2FKeys = hasU2FKeys
      self.ssoInfo = ssoInfo
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(type, forKey: .type)
      try container.encode(lastUpdateDateUnix, forKey: .lastUpdateDateUnix)
      try container.encode(recoveryPhone, forKey: .recoveryPhone)
      try container.encode(isDuoEnabled, forKey: .isDuoEnabled)
      try container.encode(hasU2FKeys, forKey: .hasU2FKeys)
      try container.encodeIfPresent(ssoInfo, forKey: .ssoInfo)
    }
  }
}
