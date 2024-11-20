import Foundation

extension SecureNitroSSOAPIClient.Authentication {
  public struct ConfirmLogin2: APIRequest {
    public static let endpoint: Endpoint = "/authentication/ConfirmLogin2"

    public let api: SecureNitroSSOAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      teamUuid: String, domainName: String, samlResponse: String, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(teamUuid: teamUuid, domainName: domainName, samlResponse: samlResponse)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var confirmLogin2: ConfirmLogin2 {
    ConfirmLogin2(api: api)
  }
}

extension SecureNitroSSOAPIClient.Authentication.ConfirmLogin2 {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case teamUuid = "teamUuid"
      case domainName = "domainName"
      case samlResponse = "samlResponse"
    }

    public let teamUuid: String
    public let domainName: String
    public let samlResponse: String

    public init(teamUuid: String, domainName: String, samlResponse: String) {
      self.teamUuid = teamUuid
      self.domainName = domainName
      self.samlResponse = samlResponse
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(teamUuid, forKey: .teamUuid)
      try container.encode(domainName, forKey: .domainName)
      try container.encode(samlResponse, forKey: .samlResponse)
    }
  }
}

extension SecureNitroSSOAPIClient.Authentication.ConfirmLogin2 {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case ssoToken = "ssoToken"
      case userServiceProviderKey = "userServiceProviderKey"
      case exists = "exists"
      case currentAuthenticationMethods = "currentAuthenticationMethods"
      case expectedAuthenticationMethods = "expectedAuthenticationMethods"
    }

    public let ssoToken: String
    public let userServiceProviderKey: String
    public let exists: Bool
    public let currentAuthenticationMethods: [String]
    public let expectedAuthenticationMethods: [String]

    public init(
      ssoToken: String, userServiceProviderKey: String, exists: Bool,
      currentAuthenticationMethods: [String], expectedAuthenticationMethods: [String]
    ) {
      self.ssoToken = ssoToken
      self.userServiceProviderKey = userServiceProviderKey
      self.exists = exists
      self.currentAuthenticationMethods = currentAuthenticationMethods
      self.expectedAuthenticationMethods = expectedAuthenticationMethods
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(ssoToken, forKey: .ssoToken)
      try container.encode(userServiceProviderKey, forKey: .userServiceProviderKey)
      try container.encode(exists, forKey: .exists)
      try container.encode(currentAuthenticationMethods, forKey: .currentAuthenticationMethods)
      try container.encode(expectedAuthenticationMethods, forKey: .expectedAuthenticationMethods)
    }
  }
}
