import Foundation

extension UserDeviceAPIClient.SharingUserdevice {
  public struct RevokeCollectionMembers: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/sharing-userdevice/RevokeCollectionMembers"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      revision: Int, collectionUUID: String, userGroupUUIDs: [String]? = nil,
      userLogins: [String]? = nil, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(
        revision: revision, collectionUUID: collectionUUID, userGroupUUIDs: userGroupUUIDs,
        userLogins: userLogins)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var revokeCollectionMembers: RevokeCollectionMembers {
    RevokeCollectionMembers(api: api)
  }
}

extension UserDeviceAPIClient.SharingUserdevice.RevokeCollectionMembers {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case revision = "revision"
      case collectionUUID = "collectionUUID"
      case userGroupUUIDs = "userGroupUUIDs"
      case userLogins = "userLogins"
    }

    public let revision: Int
    public let collectionUUID: String
    public let userGroupUUIDs: [String]?
    public let userLogins: [String]?

    public init(
      revision: Int, collectionUUID: String, userGroupUUIDs: [String]? = nil,
      userLogins: [String]? = nil
    ) {
      self.revision = revision
      self.collectionUUID = collectionUUID
      self.userGroupUUIDs = userGroupUUIDs
      self.userLogins = userLogins
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(revision, forKey: .revision)
      try container.encode(collectionUUID, forKey: .collectionUUID)
      try container.encodeIfPresent(userGroupUUIDs, forKey: .userGroupUUIDs)
      try container.encodeIfPresent(userLogins, forKey: .userLogins)
    }
  }
}

extension UserDeviceAPIClient.SharingUserdevice.RevokeCollectionMembers {
  public typealias Response = ServerResponse
}
