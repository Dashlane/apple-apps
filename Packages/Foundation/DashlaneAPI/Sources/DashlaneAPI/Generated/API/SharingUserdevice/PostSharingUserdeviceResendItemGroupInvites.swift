import Foundation

extension UserDeviceAPIClient.SharingUserdevice {
  public struct ResendItemGroupInvites: APIRequest {
    public static let endpoint: Endpoint = "/sharing-userdevice/ResendItemGroupInvites"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      revision: Int, groupId: String, users: [UserInviteResend],
      itemsForEmailing: [ItemForEmailing]? = nil, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(
        revision: revision, groupId: groupId, users: users, itemsForEmailing: itemsForEmailing)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var resendItemGroupInvites: ResendItemGroupInvites {
    ResendItemGroupInvites(api: api)
  }
}

extension UserDeviceAPIClient.SharingUserdevice.ResendItemGroupInvites {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case revision = "revision"
      case groupId = "groupId"
      case users = "users"
      case itemsForEmailing = "itemsForEmailing"
    }

    public let revision: Int
    public let groupId: String
    public let users: [UserInviteResend]
    public let itemsForEmailing: [ItemForEmailing]?

    public init(
      revision: Int, groupId: String, users: [UserInviteResend],
      itemsForEmailing: [ItemForEmailing]? = nil
    ) {
      self.revision = revision
      self.groupId = groupId
      self.users = users
      self.itemsForEmailing = itemsForEmailing
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(revision, forKey: .revision)
      try container.encode(groupId, forKey: .groupId)
      try container.encode(users, forKey: .users)
      try container.encodeIfPresent(itemsForEmailing, forKey: .itemsForEmailing)
    }
  }
}

extension UserDeviceAPIClient.SharingUserdevice.ResendItemGroupInvites {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case result = "result"
    }

    public let result: String

    public init(result: String) {
      self.result = result
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(result, forKey: .result)
    }
  }
}
