import Foundation

extension AppAPIClient.Account {
  public struct RequestAccountCreation: APIRequest {
    public static let endpoint: Endpoint = "/account/RequestAccountCreation"

    public let api: AppAPIClient

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
  public var requestAccountCreation: RequestAccountCreation {
    RequestAccountCreation(api: api)
  }
}

extension AppAPIClient.Account.RequestAccountCreation {
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

extension AppAPIClient.Account.RequestAccountCreation {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case exists = "exists"
      case accountExists = "accountExists"
      case isProposed = "isProposed"
      case isProposedExpired = "isProposedExpired"
      case isAccepted = "isAccepted"
      case emailValidity = "emailValidity"
      case sso = "sso"
      case country = "country"
      case isEuropeanUnion = "isEuropeanUnion"
      case accountType = "accountType"
      case ssoIsNitroProvider = "ssoIsNitroProvider"
      case ssoServiceProviderUrl = "ssoServiceProviderUrl"
    }

    public enum Exists: String, Sendable, Equatable, CaseIterable, Codable {
      case yes = "yes"
      case no = "no"
      case noInvalid = "no_invalid"
      case noUnlikely = "no_unlikely"
      case undecodable
      public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Self(rawValue: rawValue) ?? .undecodable
      }
    }

    public enum EmailValidity: String, Sendable, Equatable, CaseIterable, Codable {
      case valid = "valid"
      case unlikely = "unlikely"
      case invalid = "invalid"
      case undecodable
      public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Self(rawValue: rawValue) ?? .undecodable
      }
    }

    public enum AccountType: String, Sendable, Equatable, CaseIterable, Codable {
      case masterPassword = "masterPassword"
      case invisibleMasterPassword = "invisibleMasterPassword"
      case undecodable
      public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Self(rawValue: rawValue) ?? .undecodable
      }
    }

    @available(*, deprecated, message: "Deprecated in Spec")
    public let exists: Exists
    public let accountExists: Bool
    public let isProposed: Bool
    public let isProposedExpired: Bool
    public let isAccepted: Bool
    public let emailValidity: EmailValidity
    public let sso: Bool
    public let country: String?
    public let isEuropeanUnion: Bool
    public let accountType: AccountType
    public let ssoIsNitroProvider: Bool?
    public let ssoServiceProviderUrl: String?

    public init(
      exists: Exists, accountExists: Bool, isProposed: Bool, isProposedExpired: Bool,
      isAccepted: Bool, emailValidity: EmailValidity, sso: Bool, country: String?,
      isEuropeanUnion: Bool, accountType: AccountType, ssoIsNitroProvider: Bool? = nil,
      ssoServiceProviderUrl: String? = nil
    ) {
      self.exists = exists
      self.accountExists = accountExists
      self.isProposed = isProposed
      self.isProposedExpired = isProposedExpired
      self.isAccepted = isAccepted
      self.emailValidity = emailValidity
      self.sso = sso
      self.country = country
      self.isEuropeanUnion = isEuropeanUnion
      self.accountType = accountType
      self.ssoIsNitroProvider = ssoIsNitroProvider
      self.ssoServiceProviderUrl = ssoServiceProviderUrl
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(exists, forKey: .exists)
      try container.encode(accountExists, forKey: .accountExists)
      try container.encode(isProposed, forKey: .isProposed)
      try container.encode(isProposedExpired, forKey: .isProposedExpired)
      try container.encode(isAccepted, forKey: .isAccepted)
      try container.encode(emailValidity, forKey: .emailValidity)
      try container.encode(sso, forKey: .sso)
      try container.encode(country, forKey: .country)
      try container.encode(isEuropeanUnion, forKey: .isEuropeanUnion)
      try container.encode(accountType, forKey: .accountType)
      try container.encodeIfPresent(ssoIsNitroProvider, forKey: .ssoIsNitroProvider)
      try container.encodeIfPresent(ssoServiceProviderUrl, forKey: .ssoServiceProviderUrl)
    }
  }
}
