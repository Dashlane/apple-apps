import Foundation

extension UserDeviceAPIClient.SharingUserdevice {
  public struct CreateCollection: APIRequest {
    public static let endpoint: Endpoint = "/sharing-userdevice/CreateCollection"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      collectionUUID: String, collectionName: String, users: [UserCollectionUpload],
      publicKey: String, privateKey: String, teamId: Int? = nil,
      userGroups: [UserGroupCollectionInvite]? = nil, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(
        collectionUUID: collectionUUID, collectionName: collectionName, users: users,
        publicKey: publicKey, privateKey: privateKey, teamId: teamId, userGroups: userGroups)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var createCollection: CreateCollection {
    CreateCollection(api: api)
  }
}

extension UserDeviceAPIClient.SharingUserdevice.CreateCollection {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case collectionUUID = "collectionUUID"
      case collectionName = "collectionName"
      case users = "users"
      case publicKey = "publicKey"
      case privateKey = "privateKey"
      case teamId = "teamId"
      case userGroups = "userGroups"
    }

    public let collectionUUID: String
    public let collectionName: String
    public let users: [UserCollectionUpload]
    public let publicKey: String
    public let privateKey: String
    public let teamId: Int?
    public let userGroups: [UserGroupCollectionInvite]?

    public init(
      collectionUUID: String, collectionName: String, users: [UserCollectionUpload],
      publicKey: String, privateKey: String, teamId: Int? = nil,
      userGroups: [UserGroupCollectionInvite]? = nil
    ) {
      self.collectionUUID = collectionUUID
      self.collectionName = collectionName
      self.users = users
      self.publicKey = publicKey
      self.privateKey = privateKey
      self.teamId = teamId
      self.userGroups = userGroups
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(collectionUUID, forKey: .collectionUUID)
      try container.encode(collectionName, forKey: .collectionName)
      try container.encode(users, forKey: .users)
      try container.encode(publicKey, forKey: .publicKey)
      try container.encode(privateKey, forKey: .privateKey)
      try container.encodeIfPresent(teamId, forKey: .teamId)
      try container.encodeIfPresent(userGroups, forKey: .userGroups)
    }
  }
}

extension UserDeviceAPIClient.SharingUserdevice.CreateCollection {
  public typealias Response = ServerResponse
}
