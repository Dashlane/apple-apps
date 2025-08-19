import Foundation

extension UserDeviceAPIClient.SharingUserdevice {
  public struct RefuseUserGroup: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/sharing-userdevice/RefuseUserGroup"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      provisioningMethod: ProvisioningMethod, revision: Int, groupId: String,
      timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(provisioningMethod: provisioningMethod, revision: revision, groupId: groupId)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var refuseUserGroup: RefuseUserGroup {
    RefuseUserGroup(api: api)
  }
}

extension UserDeviceAPIClient.SharingUserdevice.RefuseUserGroup {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case provisioningMethod = "provisioningMethod"
      case revision = "revision"
      case groupId = "groupId"
    }

    public let provisioningMethod: ProvisioningMethod
    public let revision: Int
    public let groupId: String

    public init(provisioningMethod: ProvisioningMethod, revision: Int, groupId: String) {
      self.provisioningMethod = provisioningMethod
      self.revision = revision
      self.groupId = groupId
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(provisioningMethod, forKey: .provisioningMethod)
      try container.encode(revision, forKey: .revision)
      try container.encode(groupId, forKey: .groupId)
    }
  }
}

extension UserDeviceAPIClient.SharingUserdevice.RefuseUserGroup {
  public typealias Response = ServerResponse
}
