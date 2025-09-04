import Foundation

extension UserDeviceAPIClient.SharingUserdevice {
  public struct AddItemGroupsToCollection: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/sharing-userdevice/AddItemGroupsToCollection"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      revision: Int, collectionUUID: String, itemGroups: [Body.ItemGroupsElement],
      timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(revision: revision, collectionUUID: collectionUUID, itemGroups: itemGroups)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var addItemGroupsToCollection: AddItemGroupsToCollection {
    AddItemGroupsToCollection(api: api)
  }
}

extension UserDeviceAPIClient.SharingUserdevice.AddItemGroupsToCollection {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case revision = "revision"
      case collectionUUID = "collectionUUID"
      case itemGroups = "itemGroups"
    }

    public struct ItemGroupsElement: Codable, Hashable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case uuid = "uuid"
        case permission = "permission"
        case itemGroupKey = "itemGroupKey"
        case proposeSignature = "proposeSignature"
        case acceptSignature = "acceptSignature"
        case auditLogDetails = "auditLogDetails"
      }

      public let uuid: String
      public let permission: Permission
      public let itemGroupKey: String
      public let proposeSignature: String
      public let acceptSignature: String
      public let auditLogDetails: AuditLogDetails?

      public init(
        uuid: String, permission: Permission, itemGroupKey: String, proposeSignature: String,
        acceptSignature: String, auditLogDetails: AuditLogDetails? = nil
      ) {
        self.uuid = uuid
        self.permission = permission
        self.itemGroupKey = itemGroupKey
        self.proposeSignature = proposeSignature
        self.acceptSignature = acceptSignature
        self.auditLogDetails = auditLogDetails
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(permission, forKey: .permission)
        try container.encode(itemGroupKey, forKey: .itemGroupKey)
        try container.encode(proposeSignature, forKey: .proposeSignature)
        try container.encode(acceptSignature, forKey: .acceptSignature)
        try container.encodeIfPresent(auditLogDetails, forKey: .auditLogDetails)
      }
    }

    public let revision: Int
    public let collectionUUID: String
    public let itemGroups: [ItemGroupsElement]

    public init(revision: Int, collectionUUID: String, itemGroups: [ItemGroupsElement]) {
      self.revision = revision
      self.collectionUUID = collectionUUID
      self.itemGroups = itemGroups
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(revision, forKey: .revision)
      try container.encode(collectionUUID, forKey: .collectionUUID)
      try container.encode(itemGroups, forKey: .itemGroups)
    }
  }
}

extension UserDeviceAPIClient.SharingUserdevice.AddItemGroupsToCollection {
  public typealias Response = ServerResponse
}
