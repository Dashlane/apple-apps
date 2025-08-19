import Foundation

extension UserDeviceAPIClient.SharingUserdevice {
  public struct CreateUserGroupsItemGroup: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/sharing-userdevice/CreateUserGroupsItemGroup"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      groupId: String, teamId: Int, alias: String, groups: [UserGroupInvite],
      items: [ItemUpload]? = nil, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(groupId: groupId, teamId: teamId, alias: alias, groups: groups, items: items)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var createUserGroupsItemGroup: CreateUserGroupsItemGroup {
    CreateUserGroupsItemGroup(api: api)
  }
}

extension UserDeviceAPIClient.SharingUserdevice.CreateUserGroupsItemGroup {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case groupId = "groupId"
      case teamId = "teamId"
      case alias = "alias"
      case groups = "groups"
      case items = "items"
    }

    public let groupId: String
    public let teamId: Int
    public let alias: String
    public let groups: [UserGroupInvite]
    public let items: [ItemUpload]?

    public init(
      groupId: String, teamId: Int, alias: String, groups: [UserGroupInvite],
      items: [ItemUpload]? = nil
    ) {
      self.groupId = groupId
      self.teamId = teamId
      self.alias = alias
      self.groups = groups
      self.items = items
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(groupId, forKey: .groupId)
      try container.encode(teamId, forKey: .teamId)
      try container.encode(alias, forKey: .alias)
      try container.encode(groups, forKey: .groups)
      try container.encodeIfPresent(items, forKey: .items)
    }
  }
}

extension UserDeviceAPIClient.SharingUserdevice.CreateUserGroupsItemGroup {
  public typealias Response = ServerResponse
}
