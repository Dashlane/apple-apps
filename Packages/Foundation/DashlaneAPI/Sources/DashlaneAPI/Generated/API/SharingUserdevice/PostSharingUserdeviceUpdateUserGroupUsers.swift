import Foundation

extension UserDeviceAPIClient.SharingUserdevice {
  public struct UpdateUserGroupUsers: APIRequest {
    public static let endpoint: Endpoint = "/sharing-userdevice/UpdateUserGroupUsers"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      revision: Int, groupId: String, users: [UserUpdate], timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(revision: revision, groupId: groupId, users: users)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var updateUserGroupUsers: UpdateUserGroupUsers {
    UpdateUserGroupUsers(api: api)
  }
}

extension UserDeviceAPIClient.SharingUserdevice.UpdateUserGroupUsers {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case revision = "revision"
      case groupId = "groupId"
      case users = "users"
    }

    public let revision: Int
    public let groupId: String
    public let users: [UserUpdate]

    public init(revision: Int, groupId: String, users: [UserUpdate]) {
      self.revision = revision
      self.groupId = groupId
      self.users = users
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(revision, forKey: .revision)
      try container.encode(groupId, forKey: .groupId)
      try container.encode(users, forKey: .users)
    }
  }
}

extension UserDeviceAPIClient.SharingUserdevice.UpdateUserGroupUsers {
  public typealias Response = ServerResponse
}
