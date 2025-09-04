import Foundation

extension UserDeviceAPIClient.SharingUserdevice {
  public struct DeleteCollection: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/sharing-userdevice/DeleteCollection"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(collectionUUID: String, revision: Int, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      let body = Body(collectionUUID: collectionUUID, revision: revision)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var deleteCollection: DeleteCollection {
    DeleteCollection(api: api)
  }
}

extension UserDeviceAPIClient.SharingUserdevice.DeleteCollection {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case collectionUUID = "collectionUUID"
      case revision = "revision"
    }

    public let collectionUUID: String
    public let revision: Int

    public init(collectionUUID: String, revision: Int) {
      self.collectionUUID = collectionUUID
      self.revision = revision
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(collectionUUID, forKey: .collectionUUID)
      try container.encode(revision, forKey: .revision)
    }
  }
}

extension UserDeviceAPIClient.SharingUserdevice.DeleteCollection {
  public typealias Response = ServerResponse
}
