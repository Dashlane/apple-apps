import Foundation

extension UserDeviceAPIClient.SharingUserdevice {
  public struct DeleteItemGroup: APIRequest {
    public static let endpoint: Endpoint = "/sharing-userdevice/DeleteItemGroup"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(groupId: String, revision: Int, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      let body = Body(groupId: groupId, revision: revision)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var deleteItemGroup: DeleteItemGroup {
    DeleteItemGroup(api: api)
  }
}

extension UserDeviceAPIClient.SharingUserdevice.DeleteItemGroup {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case groupId = "groupId"
      case revision = "revision"
    }

    public let groupId: String
    public let revision: Int

    public init(groupId: String, revision: Int) {
      self.groupId = groupId
      self.revision = revision
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(groupId, forKey: .groupId)
      try container.encode(revision, forKey: .revision)
    }
  }
}

extension UserDeviceAPIClient.SharingUserdevice.DeleteItemGroup {
  public typealias Response = ServerResponse
}
