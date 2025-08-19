import Foundation

extension UserDeviceAPIClient.SharingUserdevice {
  public struct Get: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/sharing-userdevice/Get"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      collectionIds: [String]? = nil, itemGroupIds: [String]? = nil, itemIds: [String]? = nil,
      userGroupIds: [String]? = nil, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(
        collectionIds: collectionIds, itemGroupIds: itemGroupIds, itemIds: itemIds,
        userGroupIds: userGroupIds)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var get: Get {
    Get(api: api)
  }
}

extension UserDeviceAPIClient.SharingUserdevice.Get {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case collectionIds = "collectionIds"
      case itemGroupIds = "itemGroupIds"
      case itemIds = "itemIds"
      case userGroupIds = "userGroupIds"
    }

    public let collectionIds: [String]?
    public let itemGroupIds: [String]?
    public let itemIds: [String]?
    public let userGroupIds: [String]?

    public init(
      collectionIds: [String]? = nil, itemGroupIds: [String]? = nil, itemIds: [String]? = nil,
      userGroupIds: [String]? = nil
    ) {
      self.collectionIds = collectionIds
      self.itemGroupIds = itemGroupIds
      self.itemIds = itemIds
      self.userGroupIds = userGroupIds
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encodeIfPresent(collectionIds, forKey: .collectionIds)
      try container.encodeIfPresent(itemGroupIds, forKey: .itemGroupIds)
      try container.encodeIfPresent(itemIds, forKey: .itemIds)
      try container.encodeIfPresent(userGroupIds, forKey: .userGroupIds)
    }
  }
}

extension UserDeviceAPIClient.SharingUserdevice.Get {
  public typealias Response = ServerResponse
}
