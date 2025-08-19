import Foundation

extension UserDeviceAPIClient.SharingUserdevice {
  public struct RemoveItemGroupsFromCollection: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/sharing-userdevice/RemoveItemGroupsFromCollection"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      revision: Int, collectionUUID: String, itemGroupUUIDs: [String],
      itemGroupAuditLogs: [Body.ItemGroupAuditLogsElement]? = nil, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(
        revision: revision, collectionUUID: collectionUUID, itemGroupUUIDs: itemGroupUUIDs,
        itemGroupAuditLogs: itemGroupAuditLogs)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var removeItemGroupsFromCollection: RemoveItemGroupsFromCollection {
    RemoveItemGroupsFromCollection(api: api)
  }
}

extension UserDeviceAPIClient.SharingUserdevice.RemoveItemGroupsFromCollection {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case revision = "revision"
      case collectionUUID = "collectionUUID"
      case itemGroupUUIDs = "itemGroupUUIDs"
      case itemGroupAuditLogs = "itemGroupAuditLogs"
    }

    public struct ItemGroupAuditLogsElement: Codable, Hashable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case uuid = "uuid"
        case auditLogDetails = "auditLogDetails"
      }

      public let uuid: String
      public let auditLogDetails: AuditLogDetails

      public init(uuid: String, auditLogDetails: AuditLogDetails) {
        self.uuid = uuid
        self.auditLogDetails = auditLogDetails
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(auditLogDetails, forKey: .auditLogDetails)
      }
    }

    public let revision: Int
    public let collectionUUID: String
    public let itemGroupUUIDs: [String]
    public let itemGroupAuditLogs: [ItemGroupAuditLogsElement]?

    public init(
      revision: Int, collectionUUID: String, itemGroupUUIDs: [String],
      itemGroupAuditLogs: [ItemGroupAuditLogsElement]? = nil
    ) {
      self.revision = revision
      self.collectionUUID = collectionUUID
      self.itemGroupUUIDs = itemGroupUUIDs
      self.itemGroupAuditLogs = itemGroupAuditLogs
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(revision, forKey: .revision)
      try container.encode(collectionUUID, forKey: .collectionUUID)
      try container.encode(itemGroupUUIDs, forKey: .itemGroupUUIDs)
      try container.encodeIfPresent(itemGroupAuditLogs, forKey: .itemGroupAuditLogs)
    }
  }
}

extension UserDeviceAPIClient.SharingUserdevice.RemoveItemGroupsFromCollection {
  public typealias Response = ServerResponse
}
