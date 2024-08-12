import Foundation

extension UserDeviceAPIClient.SharingUserdevice {
  public struct UpdateMultipleItemGroupMembers: APIRequest {
    public static let endpoint: Endpoint = "/sharing-userdevice/UpdateMultipleItemGroupMembers"

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
  public var updateMultipleItemGroupMembers: UpdateMultipleItemGroupMembers {
    UpdateMultipleItemGroupMembers(api: api)
  }
}

extension UserDeviceAPIClient.SharingUserdevice.UpdateMultipleItemGroupMembers {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case itemgroups = "itemgroups"
    }

    public struct ItemgroupsElement: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case revision = "revision"
        case groupId = "groupId"
        case collections = "collections"
        case groups = "groups"
        case users = "users"
      }

      public let revision: Int
      public let groupId: String
      public let collections: [CollectionUpdate]?
      public let groups: [UserGroupUpdate]?
      public let users: [UserUpdate]?

      public init(
        revision: Int, groupId: String, collections: [CollectionUpdate]? = nil,
        groups: [UserGroupUpdate]? = nil, users: [UserUpdate]? = nil
      ) {
        self.revision = revision
        self.groupId = groupId
        self.collections = collections
        self.groups = groups
        self.users = users
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(revision, forKey: .revision)
        try container.encode(groupId, forKey: .groupId)
        try container.encodeIfPresent(collections, forKey: .collections)
        try container.encodeIfPresent(groups, forKey: .groups)
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

extension UserDeviceAPIClient.SharingUserdevice.UpdateMultipleItemGroupMembers {
  public typealias Response = ServerResponse
}
