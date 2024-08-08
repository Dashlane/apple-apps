import Foundation

extension UserDeviceAPIClient.SharingUserdevice {
  public struct RefuseCollection: APIRequest {
    public static let endpoint: Endpoint = "/sharing-userdevice/RefuseCollection"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      revision: Int, collectionUUID: String, userGroupUUID: String? = nil,
      timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(
        revision: revision, collectionUUID: collectionUUID, userGroupUUID: userGroupUUID)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var refuseCollection: RefuseCollection {
    RefuseCollection(api: api)
  }
}

extension UserDeviceAPIClient.SharingUserdevice.RefuseCollection {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case revision = "revision"
      case collectionUUID = "collectionUUID"
      case userGroupUUID = "userGroupUUID"
    }

    public let revision: Int
    public let collectionUUID: String
    public let userGroupUUID: String?

    public init(revision: Int, collectionUUID: String, userGroupUUID: String? = nil) {
      self.revision = revision
      self.collectionUUID = collectionUUID
      self.userGroupUUID = userGroupUUID
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(revision, forKey: .revision)
      try container.encode(collectionUUID, forKey: .collectionUUID)
      try container.encodeIfPresent(userGroupUUID, forKey: .userGroupUUID)
    }
  }
}

extension UserDeviceAPIClient.SharingUserdevice.RefuseCollection {
  public typealias Response = ServerResponse
}
