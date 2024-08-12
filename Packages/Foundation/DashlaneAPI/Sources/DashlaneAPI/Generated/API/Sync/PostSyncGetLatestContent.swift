import Foundation

extension UserDeviceAPIClient.Sync {
  public struct GetLatestContent: APIRequest {
    public static let endpoint: Endpoint = "/sync/GetLatestContent"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      timestamp: Int, transactions: [String], needsKeys: Bool, teamAdminGroups: Bool,
      timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(
        timestamp: timestamp, transactions: transactions, needsKeys: needsKeys,
        teamAdminGroups: teamAdminGroups)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var getLatestContent: GetLatestContent {
    GetLatestContent(api: api)
  }
}

extension UserDeviceAPIClient.Sync.GetLatestContent {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case timestamp = "timestamp"
      case transactions = "transactions"
      case needsKeys = "needsKeys"
      case teamAdminGroups = "teamAdminGroups"
    }

    public let timestamp: Int
    public let transactions: [String]
    public let needsKeys: Bool
    public let teamAdminGroups: Bool

    public init(timestamp: Int, transactions: [String], needsKeys: Bool, teamAdminGroups: Bool) {
      self.timestamp = timestamp
      self.transactions = transactions
      self.needsKeys = needsKeys
      self.teamAdminGroups = teamAdminGroups
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(timestamp, forKey: .timestamp)
      try container.encode(transactions, forKey: .transactions)
      try container.encode(needsKeys, forKey: .needsKeys)
      try container.encode(teamAdminGroups, forKey: .teamAdminGroups)
    }
  }
}

extension UserDeviceAPIClient.Sync.GetLatestContent {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case transactions = "transactions"
      case timestamp = "timestamp"
      case sharing2 = "sharing2"
      case syncAllowed = "syncAllowed"
      case uploadEnabled = "uploadEnabled"
      case summary = "summary"
      case fullBackup = "fullBackup"
      case keys = "keys"
    }

    public struct TransactionsElement: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case backupDate = "backupDate"
        case identifier = "identifier"
        case time = "time"
        case type = "type"
        case action = "action"
        case content = "content"
      }

      public let backupDate: Int
      public let identifier: String
      public let time: Int
      public let type: String
      public let action: SyncContentAction
      public let content: String?

      public init(
        backupDate: Int, identifier: String, time: Int, type: String, action: SyncContentAction,
        content: String? = nil
      ) {
        self.backupDate = backupDate
        self.identifier = identifier
        self.time = time
        self.type = type
        self.action = action
        self.content = content
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(backupDate, forKey: .backupDate)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(time, forKey: .time)
        try container.encode(type, forKey: .type)
        try container.encode(action, forKey: .action)
        try container.encodeIfPresent(content, forKey: .content)
      }
    }

    public struct Sharing2: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case itemGroups = "itemGroups"
        case items = "items"
        case userGroups = "userGroups"
        case collections = "collections"
      }

      public struct ItemGroupsElement: Codable, Equatable, Sendable {
        public enum CodingKeys: String, CodingKey {
          case id = "id"
          case revision = "revision"
        }

        public let id: String
        public let revision: Int

        public init(id: String, revision: Int) {
          self.id = id
          self.revision = revision
        }

        public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encode(id, forKey: .id)
          try container.encode(revision, forKey: .revision)
        }
      }

      public struct ItemsElement: Codable, Equatable, Sendable {
        public enum CodingKeys: String, CodingKey {
          case id = "id"
          case timestamp = "timestamp"
        }

        public let id: String
        public let timestamp: Int

        public init(id: String, timestamp: Int) {
          self.id = id
          self.timestamp = timestamp
        }

        public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encode(id, forKey: .id)
          try container.encode(timestamp, forKey: .timestamp)
        }
      }

      public struct UserGroupsElement: Codable, Equatable, Sendable {
        public enum CodingKeys: String, CodingKey {
          case id = "id"
          case revision = "revision"
        }

        public let id: String
        public let revision: Int

        public init(id: String, revision: Int) {
          self.id = id
          self.revision = revision
        }

        public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encode(id, forKey: .id)
          try container.encode(revision, forKey: .revision)
        }
      }

      public struct CollectionsElement: Codable, Equatable, Sendable {
        public enum CodingKeys: String, CodingKey {
          case id = "id"
          case revision = "revision"
        }

        public let id: String
        public let revision: Int

        public init(id: String, revision: Int) {
          self.id = id
          self.revision = revision
        }

        public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encode(id, forKey: .id)
          try container.encode(revision, forKey: .revision)
        }
      }

      public let itemGroups: [ItemGroupsElement]
      public let items: [ItemsElement]
      public let userGroups: [UserGroupsElement]
      public let collections: [CollectionsElement]

      public init(
        itemGroups: [ItemGroupsElement], items: [ItemsElement], userGroups: [UserGroupsElement],
        collections: [CollectionsElement]
      ) {
        self.itemGroups = itemGroups
        self.items = items
        self.userGroups = userGroups
        self.collections = collections
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(itemGroups, forKey: .itemGroups)
        try container.encode(items, forKey: .items)
        try container.encode(userGroups, forKey: .userGroups)
        try container.encode(collections, forKey: .collections)
      }
    }

    public struct Keys: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case publicKey = "publicKey"
        case privateKey = "privateKey"
      }

      public let publicKey: String
      public let privateKey: String

      public init(publicKey: String, privateKey: String) {
        self.publicKey = publicKey
        self.privateKey = privateKey
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(publicKey, forKey: .publicKey)
        try container.encode(privateKey, forKey: .privateKey)
      }
    }

    public let transactions: [TransactionsElement]
    public let timestamp: Int
    public let sharing2: Sharing2
    @available(*, deprecated, message: "Deprecated in Spec")
    public let syncAllowed: Bool
    public let uploadEnabled: Bool
    public let summary: [String: [String: Int]]
    public let fullBackup: Empty??
    public let keys: Keys?

    public init(
      transactions: [TransactionsElement], timestamp: Int, sharing2: Sharing2, syncAllowed: Bool,
      uploadEnabled: Bool, summary: [String: [String: Int]], fullBackup: Empty?? = nil,
      keys: Keys? = nil
    ) {
      self.transactions = transactions
      self.timestamp = timestamp
      self.sharing2 = sharing2
      self.syncAllowed = syncAllowed
      self.uploadEnabled = uploadEnabled
      self.summary = summary
      self.fullBackup = fullBackup
      self.keys = keys
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(transactions, forKey: .transactions)
      try container.encode(timestamp, forKey: .timestamp)
      try container.encode(sharing2, forKey: .sharing2)
      try container.encode(syncAllowed, forKey: .syncAllowed)
      try container.encode(uploadEnabled, forKey: .uploadEnabled)
      try container.encode(summary, forKey: .summary)
      try container.encodeIfPresent(fullBackup, forKey: .fullBackup)
      try container.encodeIfPresent(keys, forKey: .keys)
    }
  }
}
