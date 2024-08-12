import Foundation

extension UserDeviceAPIClient.SharingUserdevice {
  public struct InviteCollectionMembers: APIRequest {
    public static let endpoint: Endpoint = "/sharing-userdevice/InviteCollectionMembers"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      revision: Int, collectionUUID: String, userGroups: [UserGroupCollectionInvite]? = nil,
      users: [UserCollectionUpload]? = nil, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(
        revision: revision, collectionUUID: collectionUUID, userGroups: userGroups, users: users)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var inviteCollectionMembers: InviteCollectionMembers {
    InviteCollectionMembers(api: api)
  }
}

extension UserDeviceAPIClient.SharingUserdevice.InviteCollectionMembers {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case revision = "revision"
      case collectionUUID = "collectionUUID"
      case userGroups = "userGroups"
      case users = "users"
    }

    public let revision: Int
    public let collectionUUID: String
    public let userGroups: [UserGroupCollectionInvite]?
    public let users: [UserCollectionUpload]?

    public init(
      revision: Int, collectionUUID: String, userGroups: [UserGroupCollectionInvite]? = nil,
      users: [UserCollectionUpload]? = nil
    ) {
      self.revision = revision
      self.collectionUUID = collectionUUID
      self.userGroups = userGroups
      self.users = users
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(revision, forKey: .revision)
      try container.encode(collectionUUID, forKey: .collectionUUID)
      try container.encodeIfPresent(userGroups, forKey: .userGroups)
      try container.encodeIfPresent(users, forKey: .users)
    }
  }
}

extension UserDeviceAPIClient.SharingUserdevice.InviteCollectionMembers {
  public typealias Response = ServerResponse
}
