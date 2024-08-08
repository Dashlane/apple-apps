import Foundation

extension UserDeviceAPIClient.SharingUserdevice {
  public struct RevokeUserGroupUsers: APIRequest {
    public static let endpoint: Endpoint = "/sharing-userdevice/RevokeUserGroupUsers"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      provisioningMethod: ProvisioningMethod, revision: Int, groupId: String, users: [String],
      timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(
        provisioningMethod: provisioningMethod, revision: revision, groupId: groupId, users: users)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var revokeUserGroupUsers: RevokeUserGroupUsers {
    RevokeUserGroupUsers(api: api)
  }
}

extension UserDeviceAPIClient.SharingUserdevice.RevokeUserGroupUsers {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case provisioningMethod = "provisioningMethod"
      case revision = "revision"
      case groupId = "groupId"
      case users = "users"
    }

    public let provisioningMethod: ProvisioningMethod
    public let revision: Int
    public let groupId: String
    public let users: [String]

    public init(
      provisioningMethod: ProvisioningMethod, revision: Int, groupId: String, users: [String]
    ) {
      self.provisioningMethod = provisioningMethod
      self.revision = revision
      self.groupId = groupId
      self.users = users
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(provisioningMethod, forKey: .provisioningMethod)
      try container.encode(revision, forKey: .revision)
      try container.encode(groupId, forKey: .groupId)
      try container.encode(users, forKey: .users)
    }
  }
}

extension UserDeviceAPIClient.SharingUserdevice.RevokeUserGroupUsers {
  public typealias Response = ServerResponse
}
