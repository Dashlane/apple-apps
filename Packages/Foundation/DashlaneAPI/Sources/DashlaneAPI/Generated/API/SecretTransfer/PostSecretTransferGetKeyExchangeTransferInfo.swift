import Foundation

extension UserDeviceAPIClient.SecretTransfer {
  public struct GetKeyExchangeTransferInfo: APIRequest {
    public static let endpoint: Endpoint = "/secretTransfer/GetKeyExchangeTransferInfo"

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
  public var getKeyExchangeTransferInfo: GetKeyExchangeTransferInfo {
    GetKeyExchangeTransferInfo(api: api)
  }
}

extension UserDeviceAPIClient.SecretTransfer.GetKeyExchangeTransferInfo {
  public typealias Body = Empty?
}

extension UserDeviceAPIClient.SecretTransfer.GetKeyExchangeTransferInfo {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case transfer = "transfer"
    }

    public struct Transfer: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case transferId = "transferId"
        case receiver = "receiver"
      }

      public struct Receiver: Codable, Equatable, Sendable {
        public enum CodingKeys: String, CodingKey {
          case hashedPublicKey = "hashedPublicKey"
          case deviceName = "deviceName"
          case devicePlatform = "devicePlatform"
          case requestedAtDateUnix = "requestedAtDateUnix"
          case city = "city"
          case countryCode = "countryCode"
        }

        public let hashedPublicKey: String
        public let deviceName: String
        public let devicePlatform: String?
        public let requestedAtDateUnix: Int
        public let city: String?
        public let countryCode: String?

        public init(
          hashedPublicKey: String, deviceName: String, devicePlatform: String?,
          requestedAtDateUnix: Int, city: String? = nil, countryCode: String? = nil
        ) {
          self.hashedPublicKey = hashedPublicKey
          self.deviceName = deviceName
          self.devicePlatform = devicePlatform
          self.requestedAtDateUnix = requestedAtDateUnix
          self.city = city
          self.countryCode = countryCode
        }

        public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encode(hashedPublicKey, forKey: .hashedPublicKey)
          try container.encode(deviceName, forKey: .deviceName)
          try container.encode(devicePlatform, forKey: .devicePlatform)
          try container.encode(requestedAtDateUnix, forKey: .requestedAtDateUnix)
          try container.encodeIfPresent(city, forKey: .city)
          try container.encodeIfPresent(countryCode, forKey: .countryCode)
        }
      }

      public let transferId: String
      public let receiver: Receiver

      public init(transferId: String, receiver: Receiver) {
        self.transferId = transferId
        self.receiver = receiver
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(transferId, forKey: .transferId)
        try container.encode(receiver, forKey: .receiver)
      }
    }

    public let transfer: Transfer?

    public init(transfer: Transfer?) {
      self.transfer = transfer
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(transfer, forKey: .transfer)
    }
  }
}
