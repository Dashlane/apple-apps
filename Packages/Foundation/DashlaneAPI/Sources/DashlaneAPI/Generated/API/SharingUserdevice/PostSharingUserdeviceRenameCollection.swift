import Foundation

extension UserDeviceAPIClient.SharingUserdevice {
  public struct RenameCollection: APIRequest {
    public static let endpoint: Endpoint = "/sharing-userdevice/RenameCollection"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      revision: Int, collectionUUID: String, updatedName: String, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(revision: revision, collectionUUID: collectionUUID, updatedName: updatedName)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var renameCollection: RenameCollection {
    RenameCollection(api: api)
  }
}

extension UserDeviceAPIClient.SharingUserdevice.RenameCollection {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case revision = "revision"
      case collectionUUID = "collectionUUID"
      case updatedName = "updatedName"
    }

    public let revision: Int
    public let collectionUUID: String
    public let updatedName: String

    public init(revision: Int, collectionUUID: String, updatedName: String) {
      self.revision = revision
      self.collectionUUID = collectionUUID
      self.updatedName = updatedName
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(revision, forKey: .revision)
      try container.encode(collectionUUID, forKey: .collectionUUID)
      try container.encode(updatedName, forKey: .updatedName)
    }
  }
}

extension UserDeviceAPIClient.SharingUserdevice.RenameCollection {
  public typealias Response = ServerResponse
}
