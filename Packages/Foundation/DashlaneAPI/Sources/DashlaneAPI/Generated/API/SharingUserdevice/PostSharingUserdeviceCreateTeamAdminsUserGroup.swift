import Foundation

extension UserDeviceAPIClient.SharingUserdevice {
  public struct CreateTeamAdminsUserGroup: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/sharing-userdevice/CreateTeamAdminsUserGroup"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      provisioningMethod: ProvisioningMethod, groupId: String, teamId: Int, name: String,
      publicKey: String, privateKey: String, users: [UserUpload], timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(
        provisioningMethod: provisioningMethod, groupId: groupId, teamId: teamId, name: name,
        publicKey: publicKey, privateKey: privateKey, users: users)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var createTeamAdminsUserGroup: CreateTeamAdminsUserGroup {
    CreateTeamAdminsUserGroup(api: api)
  }
}

extension UserDeviceAPIClient.SharingUserdevice.CreateTeamAdminsUserGroup {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case provisioningMethod = "provisioningMethod"
      case groupId = "groupId"
      case teamId = "teamId"
      case name = "name"
      case publicKey = "publicKey"
      case privateKey = "privateKey"
      case users = "users"
    }

    public let provisioningMethod: ProvisioningMethod
    public let groupId: String
    public let teamId: Int
    public let name: String
    public let publicKey: String
    public let privateKey: String
    public let users: [UserUpload]

    public init(
      provisioningMethod: ProvisioningMethod, groupId: String, teamId: Int, name: String,
      publicKey: String, privateKey: String, users: [UserUpload]
    ) {
      self.provisioningMethod = provisioningMethod
      self.groupId = groupId
      self.teamId = teamId
      self.name = name
      self.publicKey = publicKey
      self.privateKey = privateKey
      self.users = users
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(provisioningMethod, forKey: .provisioningMethod)
      try container.encode(groupId, forKey: .groupId)
      try container.encode(teamId, forKey: .teamId)
      try container.encode(name, forKey: .name)
      try container.encode(publicKey, forKey: .publicKey)
      try container.encode(privateKey, forKey: .privateKey)
      try container.encode(users, forKey: .users)
    }
  }
}

extension UserDeviceAPIClient.SharingUserdevice.CreateTeamAdminsUserGroup {
  public typealias Response = ServerResponse
}
