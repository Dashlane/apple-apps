import Foundation

extension AppAPIClient.Account {
  public struct CreateUserWithSSO: APIRequest {
    public static let endpoint: Endpoint = "/account/CreateUserWithSSO"

    public let api: AppAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      login: String, contactEmail: String, appVersion: String, sdkVersion: String,
      platform: AccountCreateUserPlatform, settings: AccountCreateUserSettings,
      consents: [AccountCreateUserConsents], deviceName: String, country: String, osCountry: String,
      language: String, osLanguage: String, sharingKeys: AccountCreateUserSharingKeys,
      ssoToken: String, ssoServerKey: String, remoteKeys: [Body.RemoteKeysElement],
      temporaryDevice: Bool? = nil, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(
        login: login, contactEmail: contactEmail, appVersion: appVersion, sdkVersion: sdkVersion,
        platform: platform, settings: settings, consents: consents, deviceName: deviceName,
        country: country, osCountry: osCountry, language: language, osLanguage: osLanguage,
        sharingKeys: sharingKeys, ssoToken: ssoToken, ssoServerKey: ssoServerKey,
        remoteKeys: remoteKeys, temporaryDevice: temporaryDevice)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var createUserWithSSO: CreateUserWithSSO {
    CreateUserWithSSO(api: api)
  }
}

extension AppAPIClient.Account.CreateUserWithSSO {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case login = "login"
      case contactEmail = "contactEmail"
      case appVersion = "appVersion"
      case sdkVersion = "sdkVersion"
      case platform = "platform"
      case settings = "settings"
      case consents = "consents"
      case deviceName = "deviceName"
      case country = "country"
      case osCountry = "osCountry"
      case language = "language"
      case osLanguage = "osLanguage"
      case sharingKeys = "sharingKeys"
      case ssoToken = "ssoToken"
      case ssoServerKey = "ssoServerKey"
      case remoteKeys = "remoteKeys"
      case temporaryDevice = "temporaryDevice"
    }

    public struct RemoteKeysElement: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case uuid = "uuid"
        case key = "key"
        case type = "type"
      }

      public enum `Type`: String, Sendable, Equatable, CaseIterable, Codable {
        case sso = "sso"
        case undecodable
        public init(from decoder: Decoder) throws {
          let container = try decoder.singleValueContainer()
          let rawValue = try container.decode(String.self)
          self = Self(rawValue: rawValue) ?? .undecodable
        }
      }

      public let uuid: String
      public let key: String
      public let type: `Type`

      public init(uuid: String, key: String, type: `Type`) {
        self.uuid = uuid
        self.key = key
        self.type = type
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(key, forKey: .key)
        try container.encode(type, forKey: .type)
      }
    }

    public let login: String
    public let contactEmail: String
    public let appVersion: String
    public let sdkVersion: String
    public let platform: AccountCreateUserPlatform
    public let settings: AccountCreateUserSettings
    public let consents: [AccountCreateUserConsents]
    public let deviceName: String
    public let country: String
    public let osCountry: String
    public let language: String
    public let osLanguage: String
    public let sharingKeys: AccountCreateUserSharingKeys
    public let ssoToken: String
    public let ssoServerKey: String
    public let remoteKeys: [RemoteKeysElement]
    public let temporaryDevice: Bool?

    public init(
      login: String, contactEmail: String, appVersion: String, sdkVersion: String,
      platform: AccountCreateUserPlatform, settings: AccountCreateUserSettings,
      consents: [AccountCreateUserConsents], deviceName: String, country: String, osCountry: String,
      language: String, osLanguage: String, sharingKeys: AccountCreateUserSharingKeys,
      ssoToken: String, ssoServerKey: String, remoteKeys: [RemoteKeysElement],
      temporaryDevice: Bool? = nil
    ) {
      self.login = login
      self.contactEmail = contactEmail
      self.appVersion = appVersion
      self.sdkVersion = sdkVersion
      self.platform = platform
      self.settings = settings
      self.consents = consents
      self.deviceName = deviceName
      self.country = country
      self.osCountry = osCountry
      self.language = language
      self.osLanguage = osLanguage
      self.sharingKeys = sharingKeys
      self.ssoToken = ssoToken
      self.ssoServerKey = ssoServerKey
      self.remoteKeys = remoteKeys
      self.temporaryDevice = temporaryDevice
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(login, forKey: .login)
      try container.encode(contactEmail, forKey: .contactEmail)
      try container.encode(appVersion, forKey: .appVersion)
      try container.encode(sdkVersion, forKey: .sdkVersion)
      try container.encode(platform, forKey: .platform)
      try container.encode(settings, forKey: .settings)
      try container.encode(consents, forKey: .consents)
      try container.encode(deviceName, forKey: .deviceName)
      try container.encode(country, forKey: .country)
      try container.encode(osCountry, forKey: .osCountry)
      try container.encode(language, forKey: .language)
      try container.encode(osLanguage, forKey: .osLanguage)
      try container.encode(sharingKeys, forKey: .sharingKeys)
      try container.encode(ssoToken, forKey: .ssoToken)
      try container.encode(ssoServerKey, forKey: .ssoServerKey)
      try container.encode(remoteKeys, forKey: .remoteKeys)
      try container.encodeIfPresent(temporaryDevice, forKey: .temporaryDevice)
    }
  }
}

extension AppAPIClient.Account.CreateUserWithSSO {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case origin = "origin"
      case accountReset = "accountReset"
      case deviceAccessKey = "deviceAccessKey"
      case deviceSecretKey = "deviceSecretKey"
      case userAnalyticsId = "userAnalyticsId"
      case deviceAnalyticsId = "deviceAnalyticsId"
      case abTestingVersion = "abTestingVersion"
    }

    public let origin: String
    public let accountReset: Bool
    public let deviceAccessKey: String
    public let deviceSecretKey: String
    public let userAnalyticsId: String
    public let deviceAnalyticsId: String
    public let abTestingVersion: String?

    public init(
      origin: String, accountReset: Bool, deviceAccessKey: String, deviceSecretKey: String,
      userAnalyticsId: String, deviceAnalyticsId: String, abTestingVersion: String? = nil
    ) {
      self.origin = origin
      self.accountReset = accountReset
      self.deviceAccessKey = deviceAccessKey
      self.deviceSecretKey = deviceSecretKey
      self.userAnalyticsId = userAnalyticsId
      self.deviceAnalyticsId = deviceAnalyticsId
      self.abTestingVersion = abTestingVersion
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(origin, forKey: .origin)
      try container.encode(accountReset, forKey: .accountReset)
      try container.encode(deviceAccessKey, forKey: .deviceAccessKey)
      try container.encode(deviceSecretKey, forKey: .deviceSecretKey)
      try container.encode(userAnalyticsId, forKey: .userAnalyticsId)
      try container.encode(deviceAnalyticsId, forKey: .deviceAnalyticsId)
      try container.encodeIfPresent(abTestingVersion, forKey: .abTestingVersion)
    }
  }
}
