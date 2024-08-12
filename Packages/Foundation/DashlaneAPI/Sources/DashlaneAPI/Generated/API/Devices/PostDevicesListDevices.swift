import Foundation

extension UserDeviceAPIClient.Devices {
  public struct ListDevices: APIRequest {
    public static let endpoint: Endpoint = "/devices/ListDevices"

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
  public var listDevices: ListDevices {
    ListDevices(api: api)
  }
}

extension UserDeviceAPIClient.Devices.ListDevices {
  public typealias Body = Empty?
}

extension UserDeviceAPIClient.Devices.ListDevices {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case pairingGroups = "pairingGroups"
      case devices = "devices"
    }

    public struct PairingGroupsElement: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case pairingGroupUUID = "pairingGroupUUID"
        case name = "name"
        case platform = "platform"
        case devices = "devices"
        case isBucketOwner = "isBucketOwner"
      }

      public let pairingGroupUUID: String
      public let name: String?
      public let platform: String?
      public let devices: [String]
      public let isBucketOwner: Bool?

      public init(
        pairingGroupUUID: String, name: String?, platform: String?, devices: [String],
        isBucketOwner: Bool? = nil
      ) {
        self.pairingGroupUUID = pairingGroupUUID
        self.name = name
        self.platform = platform
        self.devices = devices
        self.isBucketOwner = isBucketOwner
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(pairingGroupUUID, forKey: .pairingGroupUUID)
        try container.encode(name, forKey: .name)
        try container.encode(platform, forKey: .platform)
        try container.encode(devices, forKey: .devices)
        try container.encodeIfPresent(isBucketOwner, forKey: .isBucketOwner)
      }
    }

    public struct DevicesElement: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case deviceId = "deviceId"
        case deviceName = "deviceName"
        case devicePlatform = "devicePlatform"
        case creationDateUnix = "creationDateUnix"
        case lastUpdateDateUnix = "lastUpdateDateUnix"
        case lastActivityDateUnix = "lastActivityDateUnix"
        case temporary = "temporary"
        case isBucketOwner = "isBucketOwner"
      }

      public let deviceId: String
      public let deviceName: String?
      public let devicePlatform: String?
      public let creationDateUnix: Int
      public let lastUpdateDateUnix: Int
      public let lastActivityDateUnix: Int
      public let temporary: Bool
      public let isBucketOwner: Bool?

      public init(
        deviceId: String, deviceName: String?, devicePlatform: String?, creationDateUnix: Int,
        lastUpdateDateUnix: Int, lastActivityDateUnix: Int, temporary: Bool,
        isBucketOwner: Bool? = nil
      ) {
        self.deviceId = deviceId
        self.deviceName = deviceName
        self.devicePlatform = devicePlatform
        self.creationDateUnix = creationDateUnix
        self.lastUpdateDateUnix = lastUpdateDateUnix
        self.lastActivityDateUnix = lastActivityDateUnix
        self.temporary = temporary
        self.isBucketOwner = isBucketOwner
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(deviceId, forKey: .deviceId)
        try container.encode(deviceName, forKey: .deviceName)
        try container.encode(devicePlatform, forKey: .devicePlatform)
        try container.encode(creationDateUnix, forKey: .creationDateUnix)
        try container.encode(lastUpdateDateUnix, forKey: .lastUpdateDateUnix)
        try container.encode(lastActivityDateUnix, forKey: .lastActivityDateUnix)
        try container.encode(temporary, forKey: .temporary)
        try container.encodeIfPresent(isBucketOwner, forKey: .isBucketOwner)
      }
    }

    public let pairingGroups: [PairingGroupsElement]
    public let devices: [DevicesElement]

    public init(pairingGroups: [PairingGroupsElement], devices: [DevicesElement]) {
      self.pairingGroups = pairingGroups
      self.devices = devices
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(pairingGroups, forKey: .pairingGroups)
      try container.encode(devices, forKey: .devices)
    }
  }
}
