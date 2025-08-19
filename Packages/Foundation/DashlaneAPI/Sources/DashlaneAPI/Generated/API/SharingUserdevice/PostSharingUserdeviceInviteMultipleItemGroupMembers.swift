import Foundation

extension UserDeviceAPIClient.SharingUserdevice {
  public struct InviteMultipleItemGroupMembers: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/sharing-userdevice/InviteMultipleItemGroupMembers"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(itemgroups: [Body.ItemgroupsElement], timeout: TimeInterval? = nil)
      async throws -> Response
    {
      let body = Body(itemgroups: itemgroups)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var inviteMultipleItemGroupMembers: InviteMultipleItemGroupMembers {
    InviteMultipleItemGroupMembers(api: api)
  }
}

extension UserDeviceAPIClient.SharingUserdevice.InviteMultipleItemGroupMembers {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case itemgroups = "itemgroups"
    }

    public struct ItemgroupsElement: Codable, Hashable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case revision = "revision"
        case groupId = "groupId"
        case auditLogDetails = "auditLogDetails"
        case groups = "groups"
        case itemsForEmailing = "itemsForEmailing"
        case users = "users"
      }

      public let revision: Int
      public let groupId: String
      public let auditLogDetails: AuditLogDetails?
      public let groups: [UserGroupInvite]?
      public let itemsForEmailing: [ItemForEmailing]?
      public let users: [UserInvite]?

      public init(
        revision: Int, groupId: String, auditLogDetails: AuditLogDetails? = nil,
        groups: [UserGroupInvite]? = nil, itemsForEmailing: [ItemForEmailing]? = nil,
        users: [UserInvite]? = nil
      ) {
        self.revision = revision
        self.groupId = groupId
        self.auditLogDetails = auditLogDetails
        self.groups = groups
        self.itemsForEmailing = itemsForEmailing
        self.users = users
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(revision, forKey: .revision)
        try container.encode(groupId, forKey: .groupId)
        try container.encodeIfPresent(auditLogDetails, forKey: .auditLogDetails)
        try container.encodeIfPresent(groups, forKey: .groups)
        try container.encodeIfPresent(itemsForEmailing, forKey: .itemsForEmailing)
        try container.encodeIfPresent(users, forKey: .users)
      }
    }

    public let itemgroups: [ItemgroupsElement]

    public init(itemgroups: [ItemgroupsElement]) {
      self.itemgroups = itemgroups
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(itemgroups, forKey: .itemgroups)
    }
  }
}

extension UserDeviceAPIClient.SharingUserdevice.InviteMultipleItemGroupMembers {
  public typealias Response = ServerResponse
}
