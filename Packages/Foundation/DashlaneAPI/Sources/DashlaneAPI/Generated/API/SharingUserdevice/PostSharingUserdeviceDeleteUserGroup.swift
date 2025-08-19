import Foundation

extension UserDeviceAPIClient.SharingUserdevice {
  public struct DeleteUserGroup: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/sharing-userdevice/DeleteUserGroup"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      provisioningMethod: ProvisioningMethod, groupId: String, revision: Int,
      groupKeyItem: UserGroupKeyItemDetails? = nil, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(
        provisioningMethod: provisioningMethod, groupId: groupId, revision: revision,
        groupKeyItem: groupKeyItem)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var deleteUserGroup: DeleteUserGroup {
    DeleteUserGroup(api: api)
  }
}

extension UserDeviceAPIClient.SharingUserdevice.DeleteUserGroup {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case provisioningMethod = "provisioningMethod"
      case groupId = "groupId"
      case revision = "revision"
      case groupKeyItem = "groupKeyItem"
    }

    public let provisioningMethod: ProvisioningMethod
    public let groupId: String
    public let revision: Int
    public let groupKeyItem: UserGroupKeyItemDetails?

    public init(
      provisioningMethod: ProvisioningMethod, groupId: String, revision: Int,
      groupKeyItem: UserGroupKeyItemDetails? = nil
    ) {
      self.provisioningMethod = provisioningMethod
      self.groupId = groupId
      self.revision = revision
      self.groupKeyItem = groupKeyItem
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(provisioningMethod, forKey: .provisioningMethod)
      try container.encode(groupId, forKey: .groupId)
      try container.encode(revision, forKey: .revision)
      try container.encodeIfPresent(groupKeyItem, forKey: .groupKeyItem)
    }
  }
}

extension UserDeviceAPIClient.SharingUserdevice.DeleteUserGroup {
  public typealias Response = ServerResponse
}
