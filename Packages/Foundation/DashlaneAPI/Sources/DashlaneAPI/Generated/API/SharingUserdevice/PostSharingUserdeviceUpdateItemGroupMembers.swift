import Foundation

extension UserDeviceAPIClient.SharingUserdevice {
  public struct UpdateItemGroupMembers: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/sharing-userdevice/UpdateItemGroupMembers"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      revision: Int, groupId: String, collections: [CollectionUpdate]? = nil,
      groups: [UserGroupUpdate]? = nil, users: [UserUpdate]? = nil, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(
        revision: revision, groupId: groupId, collections: collections, groups: groups, users: users
      )
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var updateItemGroupMembers: UpdateItemGroupMembers {
    UpdateItemGroupMembers(api: api)
  }
}

extension UserDeviceAPIClient.SharingUserdevice.UpdateItemGroupMembers {
  public struct Body: Codable, Hashable, Sendable {
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
}

extension UserDeviceAPIClient.SharingUserdevice.UpdateItemGroupMembers {
  public typealias Response = ServerResponse
}
