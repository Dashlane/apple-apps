import Foundation

extension AppAPIClient.Authentication {
  public struct CompleteDeviceRegistrationWithAuthTicket: APIRequest {
    public static let endpoint: Endpoint =
      "/authentication/CompleteDeviceRegistrationWithAuthTicket"

    public let api: AppAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      device: Body.Device, login: String, authTicket: String, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(device: device, login: login, authTicket: authTicket)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var completeDeviceRegistrationWithAuthTicket: CompleteDeviceRegistrationWithAuthTicket {
    CompleteDeviceRegistrationWithAuthTicket(api: api)
  }
}

extension AppAPIClient.Authentication.CompleteDeviceRegistrationWithAuthTicket {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case device = "device"
      case login = "login"
      case authTicket = "authTicket"
    }

    public struct Device: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case deviceName = "deviceName"
        case appVersion = "appVersion"
        case platform = "platform"
        case osCountry = "osCountry"
        case osLanguage = "osLanguage"
        case temporary = "temporary"
        case sdkVersion = "sdkVersion"
      }

      public enum Platform: String, Sendable, Equatable, CaseIterable, Codable {
        case serverCli = "server_cli"
        case serverMacosx = "server_macosx"
        case serverWin = "server_win"
        case desktopWin = "desktop_win"
        case desktopMacos = "desktop_macos"
        case serverCatalyst = "server_catalyst"
        case serverIphone = "server_iphone"
        case serverIpad = "server_ipad"
        case serverIpod = "server_ipod"
        case serverAndroid = "server_android"
        case web = "web"
        case webaccess = "webaccess"
        case realWebsite = "real_website"
        case website = "website"
        case serverCarbonTests = "server_carbon_tests"
        case serverWac = "server_wac"
        case serverTac = "server_tac"
        case serverLeeloo = "server_leeloo"
        case serverLeelooDev = "server_leeloo_dev"
        case serverStandalone = "server_standalone"
        case serverSafari = "server_safari"
        case unitaryTests = "unitary_tests"
        case userSupport = "userSupport"
        case undecodable
        public init(from decoder: Decoder) throws {
          let container = try decoder.singleValueContainer()
          let rawValue = try container.decode(String.self)
          self = Self(rawValue: rawValue) ?? .undecodable
        }
      }

      public let deviceName: String
      public let appVersion: String
      public let platform: Platform
      public let osCountry: String
      public let osLanguage: String
      public let temporary: Bool
      public let sdkVersion: String?

      public init(
        deviceName: String, appVersion: String, platform: Platform, osCountry: String,
        osLanguage: String, temporary: Bool, sdkVersion: String? = nil
      ) {
        self.deviceName = deviceName
        self.appVersion = appVersion
        self.platform = platform
        self.osCountry = osCountry
        self.osLanguage = osLanguage
        self.temporary = temporary
        self.sdkVersion = sdkVersion
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(deviceName, forKey: .deviceName)
        try container.encode(appVersion, forKey: .appVersion)
        try container.encode(platform, forKey: .platform)
        try container.encode(osCountry, forKey: .osCountry)
        try container.encode(osLanguage, forKey: .osLanguage)
        try container.encode(temporary, forKey: .temporary)
        try container.encodeIfPresent(sdkVersion, forKey: .sdkVersion)
      }
    }

    public let device: Device
    public let login: String
    public let authTicket: String

    public init(device: Device, login: String, authTicket: String) {
      self.device = device
      self.login = login
      self.authTicket = authTicket
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(device, forKey: .device)
      try container.encode(login, forKey: .login)
      try container.encode(authTicket, forKey: .authTicket)
    }
  }
}

extension AppAPIClient.Authentication.CompleteDeviceRegistrationWithAuthTicket {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case deviceAccessKey = "deviceAccessKey"
      case deviceSecretKey = "deviceSecretKey"
      case settings = "settings"
      case numberOfDevices = "numberOfDevices"
      case hasDesktopDevices = "hasDesktopDevices"
      case publicUserId = "publicUserId"
      case userAnalyticsId = "userAnalyticsId"
      case deviceAnalyticsId = "deviceAnalyticsId"
      case remoteKeys = "remoteKeys"
      case serverKey = "serverKey"
      case sharingKeys = "sharingKeys"
      case ssoServerKey = "ssoServerKey"
    }

    public struct Settings: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case backupDate = "backupDate"
        case identifier = "identifier"
        case time = "time"
        case content = "content"
        case type = "type"
        case action = "action"
      }

      public enum `Type`: String, Sendable, Equatable, CaseIterable, Codable {
        case settings = "SETTINGS"
        case undecodable
        public init(from decoder: Decoder) throws {
          let container = try decoder.singleValueContainer()
          let rawValue = try container.decode(String.self)
          self = Self(rawValue: rawValue) ?? .undecodable
        }
      }

      public enum Action: String, Sendable, Equatable, CaseIterable, Codable {
        case backupEdit = "BACKUP_EDIT"
        case undecodable
        public init(from decoder: Decoder) throws {
          let container = try decoder.singleValueContainer()
          let rawValue = try container.decode(String.self)
          self = Self(rawValue: rawValue) ?? .undecodable
        }
      }

      public let backupDate: Int
      public let identifier: String
      public let time: Int
      public let content: String
      public let type: `Type`
      public let action: Action

      public init(
        backupDate: Int, identifier: String, time: Int, content: String, type: `Type`,
        action: Action
      ) {
        self.backupDate = backupDate
        self.identifier = identifier
        self.time = time
        self.content = content
        self.type = type
        self.action = action
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(backupDate, forKey: .backupDate)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(time, forKey: .time)
        try container.encode(content, forKey: .content)
        try container.encode(type, forKey: .type)
        try container.encode(action, forKey: .action)
      }
    }

    public struct SharingKeys: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case privateKey = "privateKey"
        case publicKey = "publicKey"
      }

      public let privateKey: String
      public let publicKey: String

      public init(privateKey: String, publicKey: String) {
        self.privateKey = privateKey
        self.publicKey = publicKey
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(privateKey, forKey: .privateKey)
        try container.encode(publicKey, forKey: .publicKey)
      }
    }

    public let deviceAccessKey: String
    public let deviceSecretKey: String
    public let settings: Settings
    public let numberOfDevices: Int
    public let hasDesktopDevices: Bool
    public let publicUserId: String
    public let userAnalyticsId: String
    public let deviceAnalyticsId: String
    public let remoteKeys: [AuthenticationCompleteAuthTicketRemoteKeys]?
    public let serverKey: String?
    public let sharingKeys: SharingKeys?
    public let ssoServerKey: String?

    public init(
      deviceAccessKey: String, deviceSecretKey: String, settings: Settings, numberOfDevices: Int,
      hasDesktopDevices: Bool, publicUserId: String, userAnalyticsId: String,
      deviceAnalyticsId: String, remoteKeys: [AuthenticationCompleteAuthTicketRemoteKeys]? = nil,
      serverKey: String? = nil, sharingKeys: SharingKeys? = nil, ssoServerKey: String? = nil
    ) {
      self.deviceAccessKey = deviceAccessKey
      self.deviceSecretKey = deviceSecretKey
      self.settings = settings
      self.numberOfDevices = numberOfDevices
      self.hasDesktopDevices = hasDesktopDevices
      self.publicUserId = publicUserId
      self.userAnalyticsId = userAnalyticsId
      self.deviceAnalyticsId = deviceAnalyticsId
      self.remoteKeys = remoteKeys
      self.serverKey = serverKey
      self.sharingKeys = sharingKeys
      self.ssoServerKey = ssoServerKey
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(deviceAccessKey, forKey: .deviceAccessKey)
      try container.encode(deviceSecretKey, forKey: .deviceSecretKey)
      try container.encode(settings, forKey: .settings)
      try container.encode(numberOfDevices, forKey: .numberOfDevices)
      try container.encode(hasDesktopDevices, forKey: .hasDesktopDevices)
      try container.encode(publicUserId, forKey: .publicUserId)
      try container.encode(userAnalyticsId, forKey: .userAnalyticsId)
      try container.encode(deviceAnalyticsId, forKey: .deviceAnalyticsId)
      try container.encodeIfPresent(remoteKeys, forKey: .remoteKeys)
      try container.encodeIfPresent(serverKey, forKey: .serverKey)
      try container.encodeIfPresent(sharingKeys, forKey: .sharingKeys)
      try container.encodeIfPresent(ssoServerKey, forKey: .ssoServerKey)
    }
  }
}
