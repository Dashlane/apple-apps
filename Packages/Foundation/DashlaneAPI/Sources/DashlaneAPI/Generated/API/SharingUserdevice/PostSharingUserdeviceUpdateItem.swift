import Foundation

extension UserDeviceAPIClient.SharingUserdevice {
  public struct UpdateItem: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/sharing-userdevice/UpdateItem"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      itemId: String, content: String, timestamp: Int, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(itemId: itemId, content: content, timestamp: timestamp)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var updateItem: UpdateItem {
    UpdateItem(api: api)
  }
}

extension UserDeviceAPIClient.SharingUserdevice.UpdateItem {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case itemId = "itemId"
      case content = "content"
      case timestamp = "timestamp"
    }

    public let itemId: String
    public let content: String
    public let timestamp: Int

    public init(itemId: String, content: String, timestamp: Int) {
      self.itemId = itemId
      self.content = content
      self.timestamp = timestamp
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(itemId, forKey: .itemId)
      try container.encode(content, forKey: .content)
      try container.encode(timestamp, forKey: .timestamp)
    }
  }
}

extension UserDeviceAPIClient.SharingUserdevice.UpdateItem {
  public typealias Response = ServerResponse
}
