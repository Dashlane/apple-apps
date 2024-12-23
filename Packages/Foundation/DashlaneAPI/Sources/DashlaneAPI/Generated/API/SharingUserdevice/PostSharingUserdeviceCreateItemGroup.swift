import Foundation

extension UserDeviceAPIClient.SharingUserdevice {
  public struct CreateItemGroup: APIRequest {
    public static let endpoint: Endpoint = "/sharing-userdevice/CreateItemGroup"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      groupId: String, users: [UserUpload], items: [ItemUpload],
      auditLogDetails: AuditLogDetails? = nil, groups: [UserGroupInvite]? = nil,
      itemsForEmailing: [ItemForEmailing]? = nil, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(
        groupId: groupId, users: users, items: items, auditLogDetails: auditLogDetails,
        groups: groups, itemsForEmailing: itemsForEmailing)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var createItemGroup: CreateItemGroup {
    CreateItemGroup(api: api)
  }
}

extension UserDeviceAPIClient.SharingUserdevice.CreateItemGroup {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case groupId = "groupId"
      case users = "users"
      case items = "items"
      case auditLogDetails = "auditLogDetails"
      case groups = "groups"
      case itemsForEmailing = "itemsForEmailing"
    }

    public let groupId: String
    public let users: [UserUpload]
    public let items: [ItemUpload]
    public let auditLogDetails: AuditLogDetails?
    public let groups: [UserGroupInvite]?
    public let itemsForEmailing: [ItemForEmailing]?

    public init(
      groupId: String, users: [UserUpload], items: [ItemUpload],
      auditLogDetails: AuditLogDetails? = nil, groups: [UserGroupInvite]? = nil,
      itemsForEmailing: [ItemForEmailing]? = nil
    ) {
      self.groupId = groupId
      self.users = users
      self.items = items
      self.auditLogDetails = auditLogDetails
      self.groups = groups
      self.itemsForEmailing = itemsForEmailing
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(groupId, forKey: .groupId)
      try container.encode(users, forKey: .users)
      try container.encode(items, forKey: .items)
      try container.encodeIfPresent(auditLogDetails, forKey: .auditLogDetails)
      try container.encodeIfPresent(groups, forKey: .groups)
      try container.encodeIfPresent(itemsForEmailing, forKey: .itemsForEmailing)
    }
  }
}

extension UserDeviceAPIClient.SharingUserdevice.CreateItemGroup {
  public typealias Response = ServerResponse
}
