import Foundation

extension UserDeviceAPIClient.SharingUserdevice {
  public struct RenameUserGroup: APIRequest {
    public static let endpoint: Endpoint = "/sharing-userdevice/RenameUserGroup"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      provisioningMethod: ProvisioningMethod, revision: Int, groupId: String, name: String,
      timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(
        provisioningMethod: provisioningMethod, revision: revision, groupId: groupId, name: name)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var renameUserGroup: RenameUserGroup {
    RenameUserGroup(api: api)
  }
}

extension UserDeviceAPIClient.SharingUserdevice.RenameUserGroup {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case provisioningMethod = "provisioningMethod"
      case revision = "revision"
      case groupId = "groupId"
      case name = "name"
    }

    public let provisioningMethod: ProvisioningMethod
    public let revision: Int
    public let groupId: String
    public let name: String

    public init(
      provisioningMethod: ProvisioningMethod, revision: Int, groupId: String, name: String
    ) {
      self.provisioningMethod = provisioningMethod
      self.revision = revision
      self.groupId = groupId
      self.name = name
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(provisioningMethod, forKey: .provisioningMethod)
      try container.encode(revision, forKey: .revision)
      try container.encode(groupId, forKey: .groupId)
      try container.encode(name, forKey: .name)
    }
  }
}

extension UserDeviceAPIClient.SharingUserdevice.RenameUserGroup {
  public typealias Response = ServerResponse
}
