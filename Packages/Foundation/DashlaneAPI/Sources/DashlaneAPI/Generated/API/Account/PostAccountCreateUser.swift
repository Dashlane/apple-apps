import Foundation

extension AppAPIClient.Account {
  public struct CreateUser: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/account/CreateUser"

    public let api: AppAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      login: String, appVersion: String, platform: AccountCreateUserPlatform,
      settings: AccountCreateUserSettings, consents: [AccountCreateUserConsents],
      deviceName: String, country: String, osCountry: String, language: String, osLanguage: String,
      sharingKeys: AccountCreateUserSharingKeys, abTestingVersion: String? = nil,
      accountType: AccountType? = nil, askM2dToken: Bool? = nil, contactEmail: String? = nil,
      contactPhone: String? = nil, origin: String? = nil,
      remoteKeys: [Body.RemoteKeysElement]? = nil, sdkVersion: String? = nil,
      securityKey: Body.SecurityKey? = nil, temporaryDevice: Bool? = nil,
      timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(
        login: login, appVersion: appVersion, platform: platform, settings: settings,
        consents: consents, deviceName: deviceName, country: country, osCountry: osCountry,
        language: language, osLanguage: osLanguage, sharingKeys: sharingKeys,
        abTestingVersion: abTestingVersion, accountType: accountType, askM2dToken: askM2dToken,
        contactEmail: contactEmail, contactPhone: contactPhone, origin: origin,
        remoteKeys: remoteKeys, sdkVersion: sdkVersion, securityKey: securityKey,
        temporaryDevice: temporaryDevice)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var createUser: CreateUser {
    CreateUser(api: api)
  }
}

extension AppAPIClient.Account.CreateUser {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case login = "login"
      case appVersion = "appVersion"
      case platform = "platform"
      case settings = "settings"
      case consents = "consents"
      case deviceName = "deviceName"
      case country = "country"
      case osCountry = "osCountry"
      case language = "language"
      case osLanguage = "osLanguage"
      case sharingKeys = "sharingKeys"
      case abTestingVersion = "abTestingVersion"
      case accountType = "accountType"
      case askM2dToken = "askM2dToken"
      case contactEmail = "contactEmail"
      case contactPhone = "contactPhone"
      case origin = "origin"
      case remoteKeys = "remoteKeys"
      case sdkVersion = "sdkVersion"
      case securityKey = "securityKey"
      case temporaryDevice = "temporaryDevice"
    }

    public struct RemoteKeysElement: Codable, Hashable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case uuid = "uuid"
        case key = "key"
        case type = "type"
      }

      public enum `Type`: String, Sendable, Hashable, Codable, CaseIterable {
        case masterPassword = "master_password"
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

    public struct SecurityKey: Codable, Hashable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case credential = "credential"
        case encryptedVaultKey = "encryptedVaultKey"
      }

      public struct Credential: Codable, Hashable, Sendable {
        public enum CodingKeys: String, CodingKey {
          case id = "id"
          case rawId = "rawId"
          case response = "response"
          case authenticatorAttachment = "authenticatorAttachment"
          case type = "type"
          case clientExtensionResults = "clientExtensionResults"
        }

        public struct Response: Codable, Hashable, Sendable {
          public enum CodingKeys: String, CodingKey {
            case clientDataJSON = "clientDataJSON"
            case attestationObject = "attestationObject"
            case transports = "transports"
            case authenticatorData = "authenticatorData"
            case publicKey = "publicKey"
            case publicKeyAlgorithm = "publicKeyAlgorithm"
          }

          public enum TransportsElement: String, Sendable, Hashable, Codable, CaseIterable {
            case ble = "ble"
            case cable = "cable"
            case hybrid = "hybrid"
            case `internal` = "internal"
            case nfc = "nfc"
            case smartCard = "smart-card"
            case usb = "usb"
            case undecodable
            public init(from decoder: Decoder) throws {
              let container = try decoder.singleValueContainer()
              let rawValue = try container.decode(String.self)
              self = Self(rawValue: rawValue) ?? .undecodable
            }
          }

          public let clientDataJSON: String
          public let attestationObject: String
          public let transports: [TransportsElement]
          public let authenticatorData: String?
          public let publicKey: String?
          public let publicKeyAlgorithm: Int?

          public init(
            clientDataJSON: String, attestationObject: String, transports: [TransportsElement],
            authenticatorData: String? = nil, publicKey: String? = nil,
            publicKeyAlgorithm: Int? = nil
          ) {
            self.clientDataJSON = clientDataJSON
            self.attestationObject = attestationObject
            self.transports = transports
            self.authenticatorData = authenticatorData
            self.publicKey = publicKey
            self.publicKeyAlgorithm = publicKeyAlgorithm
          }

          public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(clientDataJSON, forKey: .clientDataJSON)
            try container.encode(attestationObject, forKey: .attestationObject)
            try container.encode(transports, forKey: .transports)
            try container.encodeIfPresent(authenticatorData, forKey: .authenticatorData)
            try container.encodeIfPresent(publicKey, forKey: .publicKey)
            try container.encodeIfPresent(publicKeyAlgorithm, forKey: .publicKeyAlgorithm)
          }
        }

        public enum AuthenticatorAttachment: String, Sendable, Hashable, Codable, CaseIterable {
          case crossPlatform = "cross-platform"
          case undecodable
          public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            self = Self(rawValue: rawValue) ?? .undecodable
          }
        }

        public enum `Type`: String, Sendable, Hashable, Codable, CaseIterable {
          case publicKey = "public-key"
          case undecodable
          public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            self = Self(rawValue: rawValue) ?? .undecodable
          }
        }

        public struct ClientExtensionResults: Codable, Hashable, Sendable {
          public enum CodingKeys: String, CodingKey {
            case credProps = "credProps"
            case prf = "prf"
          }

          public struct CredProps: Codable, Hashable, Sendable {
            public enum CodingKeys: String, CodingKey {
              case rk = "rk"
            }

            public let rk: Bool

            public init(rk: Bool) {
              self.rk = rk
            }

            public func encode(to encoder: Encoder) throws {
              var container = encoder.container(keyedBy: CodingKeys.self)
              try container.encode(rk, forKey: .rk)
            }
          }

          public struct Prf: Codable, Hashable, Sendable {
            public enum CodingKeys: String, CodingKey {
              case enabled = "enabled"
            }

            public let enabled: Bool

            public init(enabled: Bool) {
              self.enabled = enabled
            }

            public func encode(to encoder: Encoder) throws {
              var container = encoder.container(keyedBy: CodingKeys.self)
              try container.encode(enabled, forKey: .enabled)
            }
          }

          public let credProps: CredProps
          public let prf: Prf

          public init(credProps: CredProps, prf: Prf) {
            self.credProps = credProps
            self.prf = prf
          }

          public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(credProps, forKey: .credProps)
            try container.encode(prf, forKey: .prf)
          }
        }

        public let id: String
        public let rawId: String
        public let response: Response
        public let authenticatorAttachment: AuthenticatorAttachment
        public let type: `Type`
        public let clientExtensionResults: ClientExtensionResults

        public init(
          id: String, rawId: String, response: Response,
          authenticatorAttachment: AuthenticatorAttachment, type: `Type`,
          clientExtensionResults: ClientExtensionResults
        ) {
          self.id = id
          self.rawId = rawId
          self.response = response
          self.authenticatorAttachment = authenticatorAttachment
          self.type = type
          self.clientExtensionResults = clientExtensionResults
        }

        public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encode(id, forKey: .id)
          try container.encode(rawId, forKey: .rawId)
          try container.encode(response, forKey: .response)
          try container.encode(authenticatorAttachment, forKey: .authenticatorAttachment)
          try container.encode(type, forKey: .type)
          try container.encode(clientExtensionResults, forKey: .clientExtensionResults)
        }
      }

      public let credential: Credential
      public let encryptedVaultKey: String

      public init(credential: Credential, encryptedVaultKey: String) {
        self.credential = credential
        self.encryptedVaultKey = encryptedVaultKey
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(credential, forKey: .credential)
        try container.encode(encryptedVaultKey, forKey: .encryptedVaultKey)
      }
    }

    public let login: String
    public let appVersion: String
    public let platform: AccountCreateUserPlatform
    public let settings: AccountCreateUserSettings
    public let consents: [AccountCreateUserConsents]
    public let deviceName: String
    public let country: String
    public let osCountry: String
    public let language: String
    public let osLanguage: String
    public let sharingKeys: AccountCreateUserSharingKeys
    public let abTestingVersion: String?
    public let accountType: AccountType?
    @available(*, deprecated, message: "Deprecated in Spec")
    public let askM2dToken: Bool?
    public let contactEmail: String?
    public let contactPhone: String?
    public let origin: String?
    public let remoteKeys: [RemoteKeysElement]?
    public let sdkVersion: String?
    public let securityKey: SecurityKey?
    public let temporaryDevice: Bool?

    public init(
      login: String, appVersion: String, platform: AccountCreateUserPlatform,
      settings: AccountCreateUserSettings, consents: [AccountCreateUserConsents],
      deviceName: String, country: String, osCountry: String, language: String, osLanguage: String,
      sharingKeys: AccountCreateUserSharingKeys, abTestingVersion: String? = nil,
      accountType: AccountType? = nil, askM2dToken: Bool? = nil, contactEmail: String? = nil,
      contactPhone: String? = nil, origin: String? = nil, remoteKeys: [RemoteKeysElement]? = nil,
      sdkVersion: String? = nil, securityKey: SecurityKey? = nil, temporaryDevice: Bool? = nil
    ) {
      self.login = login
      self.appVersion = appVersion
      self.platform = platform
      self.settings = settings
      self.consents = consents
      self.deviceName = deviceName
      self.country = country
      self.osCountry = osCountry
      self.language = language
      self.osLanguage = osLanguage
      self.sharingKeys = sharingKeys
      self.abTestingVersion = abTestingVersion
      self.accountType = accountType
      self.askM2dToken = askM2dToken
      self.contactEmail = contactEmail
      self.contactPhone = contactPhone
      self.origin = origin
      self.remoteKeys = remoteKeys
      self.sdkVersion = sdkVersion
      self.securityKey = securityKey
      self.temporaryDevice = temporaryDevice
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(login, forKey: .login)
      try container.encode(appVersion, forKey: .appVersion)
      try container.encode(platform, forKey: .platform)
      try container.encode(settings, forKey: .settings)
      try container.encode(consents, forKey: .consents)
      try container.encode(deviceName, forKey: .deviceName)
      try container.encode(country, forKey: .country)
      try container.encode(osCountry, forKey: .osCountry)
      try container.encode(language, forKey: .language)
      try container.encode(osLanguage, forKey: .osLanguage)
      try container.encode(sharingKeys, forKey: .sharingKeys)
      try container.encodeIfPresent(abTestingVersion, forKey: .abTestingVersion)
      try container.encodeIfPresent(accountType, forKey: .accountType)
      try container.encodeIfPresent(askM2dToken, forKey: .askM2dToken)
      try container.encodeIfPresent(contactEmail, forKey: .contactEmail)
      try container.encodeIfPresent(contactPhone, forKey: .contactPhone)
      try container.encodeIfPresent(origin, forKey: .origin)
      try container.encodeIfPresent(remoteKeys, forKey: .remoteKeys)
      try container.encodeIfPresent(sdkVersion, forKey: .sdkVersion)
      try container.encodeIfPresent(securityKey, forKey: .securityKey)
      try container.encodeIfPresent(temporaryDevice, forKey: .temporaryDevice)
    }
  }
}

extension AppAPIClient.Account.CreateUser {
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case origin = "origin"
      case accountReset = "accountReset"
      case deviceAccessKey = "deviceAccessKey"
      case deviceSecretKey = "deviceSecretKey"
      case userAnalyticsId = "userAnalyticsId"
      case deviceAnalyticsId = "deviceAnalyticsId"
      case abTestingVersion = "abTestingVersion"
      case token = "token"
    }

    public let origin: String
    public let accountReset: Bool
    public let deviceAccessKey: String
    public let deviceSecretKey: String
    public let userAnalyticsId: String
    public let deviceAnalyticsId: String
    public let abTestingVersion: String?
    @available(*, deprecated, message: "Deprecated in Spec")
    public let token: String?

    public init(
      origin: String, accountReset: Bool, deviceAccessKey: String, deviceSecretKey: String,
      userAnalyticsId: String, deviceAnalyticsId: String, abTestingVersion: String? = nil,
      token: String? = nil
    ) {
      self.origin = origin
      self.accountReset = accountReset
      self.deviceAccessKey = deviceAccessKey
      self.deviceSecretKey = deviceSecretKey
      self.userAnalyticsId = userAnalyticsId
      self.deviceAnalyticsId = deviceAnalyticsId
      self.abTestingVersion = abTestingVersion
      self.token = token
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
      try container.encodeIfPresent(token, forKey: .token)
    }
  }
}
