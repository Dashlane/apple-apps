import Foundation

extension UserDeviceAPIClient.SharingUserdevice {
  public struct AddItems: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/sharing-userdevice/AddItems"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      revision: Int, groupId: String, items: [ItemUpload], timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(revision: revision, groupId: groupId, items: items)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var addItems: AddItems {
    AddItems(api: api)
  }
}

extension UserDeviceAPIClient.SharingUserdevice.AddItems {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case revision = "revision"
      case groupId = "groupId"
      case items = "items"
    }

    public let revision: Int
    public let groupId: String
    public let items: [ItemUpload]

    public init(revision: Int, groupId: String, items: [ItemUpload]) {
      self.revision = revision
      self.groupId = groupId
      self.items = items
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(revision, forKey: .revision)
      try container.encode(groupId, forKey: .groupId)
      try container.encode(items, forKey: .items)
    }
  }
}

extension UserDeviceAPIClient.SharingUserdevice.AddItems {
  public typealias Response = ServerResponse
}
