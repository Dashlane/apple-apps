import Foundation

extension UserDeviceAPIClient.SharingUserdevice {
  public struct RefuseItemGroup: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/sharing-userdevice/RefuseItemGroup"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      revision: Int, groupId: String, auditLogDetails: AuditLogDetails? = nil,
      itemsForEmailing: [ItemForEmailing]? = nil, userGroupId: String? = nil,
      timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(
        revision: revision, groupId: groupId, auditLogDetails: auditLogDetails,
        itemsForEmailing: itemsForEmailing, userGroupId: userGroupId)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var refuseItemGroup: RefuseItemGroup {
    RefuseItemGroup(api: api)
  }
}

extension UserDeviceAPIClient.SharingUserdevice.RefuseItemGroup {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case revision = "revision"
      case groupId = "groupId"
      case auditLogDetails = "auditLogDetails"
      case itemsForEmailing = "itemsForEmailing"
      case userGroupId = "userGroupId"
    }

    public let revision: Int
    public let groupId: String
    public let auditLogDetails: AuditLogDetails?
    public let itemsForEmailing: [ItemForEmailing]?
    public let userGroupId: String?

    public init(
      revision: Int, groupId: String, auditLogDetails: AuditLogDetails? = nil,
      itemsForEmailing: [ItemForEmailing]? = nil, userGroupId: String? = nil
    ) {
      self.revision = revision
      self.groupId = groupId
      self.auditLogDetails = auditLogDetails
      self.itemsForEmailing = itemsForEmailing
      self.userGroupId = userGroupId
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(revision, forKey: .revision)
      try container.encode(groupId, forKey: .groupId)
      try container.encodeIfPresent(auditLogDetails, forKey: .auditLogDetails)
      try container.encodeIfPresent(itemsForEmailing, forKey: .itemsForEmailing)
      try container.encodeIfPresent(userGroupId, forKey: .userGroupId)
    }
  }
}

extension UserDeviceAPIClient.SharingUserdevice.RefuseItemGroup {
  public typealias Response = ServerResponse
}
