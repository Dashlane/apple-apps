import Foundation

extension UserDeviceAPIClient.Sync {
  public struct UploadContent: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/sync/UploadContent"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      timestamp: Int, transactions: [Body.TransactionsElement], sharingKeys: SyncSharingKeys? = nil,
      timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(timestamp: timestamp, transactions: transactions, sharingKeys: sharingKeys)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var uploadContent: UploadContent {
    UploadContent(api: api)
  }
}

extension UserDeviceAPIClient.Sync.UploadContent {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case timestamp = "timestamp"
      case transactions = "transactions"
      case sharingKeys = "sharingKeys"
    }

    public struct TransactionsElement: Codable, Hashable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case identifier = "identifier"
        case time = "time"
        case type = "type"
        case action = "action"
        case content = "content"
      }

      public let identifier: String
      public let time: Int
      public let type: String
      public let action: SyncContentAction
      public let content: String?

      public init(
        identifier: String, time: Int, type: String, action: SyncContentAction,
        content: String? = nil
      ) {
        self.identifier = identifier
        self.time = time
        self.type = type
        self.action = action
        self.content = content
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(time, forKey: .time)
        try container.encode(type, forKey: .type)
        try container.encode(action, forKey: .action)
        try container.encodeIfPresent(content, forKey: .content)
      }
    }

    public let timestamp: Int
    public let transactions: [TransactionsElement]
    public let sharingKeys: SyncSharingKeys?

    public init(
      timestamp: Int, transactions: [TransactionsElement], sharingKeys: SyncSharingKeys? = nil
    ) {
      self.timestamp = timestamp
      self.transactions = transactions
      self.sharingKeys = sharingKeys
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(timestamp, forKey: .timestamp)
      try container.encode(transactions, forKey: .transactions)
      try container.encodeIfPresent(sharingKeys, forKey: .sharingKeys)
    }
  }
}

extension UserDeviceAPIClient.Sync.UploadContent {
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case timestamp = "timestamp"
      case summary = "summary"
    }

    public let timestamp: Int
    public let summary: [String: [String: Int]]

    public init(timestamp: Int, summary: [String: [String: Int]]) {
      self.timestamp = timestamp
      self.summary = summary
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(timestamp, forKey: .timestamp)
      try container.encode(summary, forKey: .summary)
    }
  }
}
