import Foundation

extension UserDeviceAPIClient.SharingUserdevice {
  public struct AcceptUserGroup: APIRequest {
    public static let endpoint: Endpoint = "/sharing-userdevice/AcceptUserGroup"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      provisioningMethod: ProvisioningMethod, revision: Int, groupId: String,
      acceptSignature: String, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(
        provisioningMethod: provisioningMethod, revision: revision, groupId: groupId,
        acceptSignature: acceptSignature)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var acceptUserGroup: AcceptUserGroup {
    AcceptUserGroup(api: api)
  }
}

extension UserDeviceAPIClient.SharingUserdevice.AcceptUserGroup {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case provisioningMethod = "provisioningMethod"
      case revision = "revision"
      case groupId = "groupId"
      case acceptSignature = "acceptSignature"
    }

    public let provisioningMethod: ProvisioningMethod
    public let revision: Int
    public let groupId: String
    public let acceptSignature: String

    public init(
      provisioningMethod: ProvisioningMethod, revision: Int, groupId: String,
      acceptSignature: String
    ) {
      self.provisioningMethod = provisioningMethod
      self.revision = revision
      self.groupId = groupId
      self.acceptSignature = acceptSignature
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(provisioningMethod, forKey: .provisioningMethod)
      try container.encode(revision, forKey: .revision)
      try container.encode(groupId, forKey: .groupId)
      try container.encode(acceptSignature, forKey: .acceptSignature)
    }
  }
}

extension UserDeviceAPIClient.SharingUserdevice.AcceptUserGroup {
  public typealias Response = ServerResponse
}
