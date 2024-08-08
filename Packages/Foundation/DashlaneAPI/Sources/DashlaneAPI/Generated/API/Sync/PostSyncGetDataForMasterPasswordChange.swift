import Foundation

extension UserDeviceAPIClient.Sync {
  public struct GetDataForMasterPasswordChange: APIRequest {
    public static let endpoint: Endpoint = "/sync/GetDataForMasterPasswordChange"

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
  public var getDataForMasterPasswordChange: GetDataForMasterPasswordChange {
    GetDataForMasterPasswordChange(api: api)
  }
}

extension UserDeviceAPIClient.Sync.GetDataForMasterPasswordChange {
  public typealias Body = Empty?
}

extension UserDeviceAPIClient.Sync.GetDataForMasterPasswordChange {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case timestamp = "timestamp"
      case otpStatus = "otpStatus"
      case data = "data"
    }

    public enum OtpStatus: String, Sendable, Equatable, CaseIterable, Codable {
      case disabled = "disabled"
      case newDevice = "newDevice"
      case login = "login"
      case undecodable
      public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Self(rawValue: rawValue) ?? .undecodable
      }
    }

    public struct DataValue: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case transactions = "transactions"
        case sharingKeys = "sharingKeys"
      }

      public struct TransactionsElement: Codable, Equatable, Sendable {
        public enum CodingKeys: String, CodingKey {
          case backupDate = "backupDate"
          case identifier = "identifier"
          case time = "time"
          case content = "content"
          case type = "type"
          case action = "action"
        }

        public let backupDate: Int
        public let identifier: String
        public let time: Int
        public let content: String
        public let type: String
        public let action: SyncDataAction

        public init(
          backupDate: Int, identifier: String, time: Int, content: String, type: String,
          action: SyncDataAction
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

      public let transactions: [TransactionsElement]
      public let sharingKeys: SyncSharingKeys

      public init(transactions: [TransactionsElement], sharingKeys: SyncSharingKeys) {
        self.transactions = transactions
        self.sharingKeys = sharingKeys
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(transactions, forKey: .transactions)
        try container.encode(sharingKeys, forKey: .sharingKeys)
      }
    }

    public let timestamp: Int
    public let otpStatus: OtpStatus
    public let data: DataValue

    public init(timestamp: Int, otpStatus: OtpStatus, data: DataValue) {
      self.timestamp = timestamp
      self.otpStatus = otpStatus
      self.data = data
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(timestamp, forKey: .timestamp)
      try container.encode(otpStatus, forKey: .otpStatus)
      try container.encode(data, forKey: .data)
    }
  }
}
