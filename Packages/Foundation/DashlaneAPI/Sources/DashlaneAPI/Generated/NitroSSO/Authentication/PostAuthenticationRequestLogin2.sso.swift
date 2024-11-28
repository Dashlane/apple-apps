import Foundation

extension SecureNitroSSOAPIClient.Authentication {
  public struct RequestLogin2: APIRequest {
    public static let endpoint: Endpoint = "/authentication/RequestLogin2"

    public let api: SecureNitroSSOAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(login: String, timeout: TimeInterval? = nil) async throws -> Response
    {
      let body = Body(login: login)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var requestLogin2: RequestLogin2 {
    RequestLogin2(api: api)
  }
}

extension SecureNitroSSOAPIClient.Authentication.RequestLogin2 {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case login = "login"
    }

    public let login: String

    public init(login: String) {
      self.login = login
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(login, forKey: .login)
    }
  }
}

extension SecureNitroSSOAPIClient.Authentication.RequestLogin2 {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case domainName = "domainName"
      case idpAuthorizeUrl = "idpAuthorizeUrl"
      case spCallbackUrl = "spCallbackUrl"
      case teamUuid = "teamUuid"
      case validatedDomains = "validatedDomains"
    }

    public let domainName: String
    public let idpAuthorizeUrl: String
    public let spCallbackUrl: String
    public let teamUuid: String
    public let validatedDomains: [String]

    public init(
      domainName: String, idpAuthorizeUrl: String, spCallbackUrl: String, teamUuid: String,
      validatedDomains: [String]
    ) {
      self.domainName = domainName
      self.idpAuthorizeUrl = idpAuthorizeUrl
      self.spCallbackUrl = spCallbackUrl
      self.teamUuid = teamUuid
      self.validatedDomains = validatedDomains
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(domainName, forKey: .domainName)
      try container.encode(idpAuthorizeUrl, forKey: .idpAuthorizeUrl)
      try container.encode(spCallbackUrl, forKey: .spCallbackUrl)
      try container.encode(teamUuid, forKey: .teamUuid)
      try container.encode(validatedDomains, forKey: .validatedDomains)
    }
  }
}
