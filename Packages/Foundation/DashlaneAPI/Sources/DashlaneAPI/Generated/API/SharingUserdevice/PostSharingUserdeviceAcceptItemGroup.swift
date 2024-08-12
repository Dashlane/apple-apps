import Foundation

extension UserDeviceAPIClient.SharingUserdevice {
  public struct AcceptItemGroup: APIRequest {
    public static let endpoint: Endpoint = "/sharing-userdevice/AcceptItemGroup"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      revision: Int, groupId: String, acceptSignature: String,
      auditLogDetails: AuditLogDetails? = nil, autoAccept: Bool? = nil,
      itemsForEmailing: [ItemForEmailing]? = nil, userGroupId: String? = nil,
      timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(
        revision: revision, groupId: groupId, acceptSignature: acceptSignature,
        auditLogDetails: auditLogDetails, autoAccept: autoAccept,
        itemsForEmailing: itemsForEmailing, userGroupId: userGroupId)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var acceptItemGroup: AcceptItemGroup {
    AcceptItemGroup(api: api)
  }
}

extension UserDeviceAPIClient.SharingUserdevice.AcceptItemGroup {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case revision = "revision"
      case groupId = "groupId"
      case acceptSignature = "acceptSignature"
      case auditLogDetails = "auditLogDetails"
      case autoAccept = "autoAccept"
      case itemsForEmailing = "itemsForEmailing"
      case userGroupId = "userGroupId"
    }

    public let revision: Int
    public let groupId: String
    public let acceptSignature: String
    public let auditLogDetails: AuditLogDetails?
    public let autoAccept: Bool?
    public let itemsForEmailing: [ItemForEmailing]?
    public let userGroupId: String?

    public init(
      revision: Int, groupId: String, acceptSignature: String,
      auditLogDetails: AuditLogDetails? = nil, autoAccept: Bool? = nil,
      itemsForEmailing: [ItemForEmailing]? = nil, userGroupId: String? = nil
    ) {
      self.revision = revision
      self.groupId = groupId
      self.acceptSignature = acceptSignature
      self.auditLogDetails = auditLogDetails
      self.autoAccept = autoAccept
      self.itemsForEmailing = itemsForEmailing
      self.userGroupId = userGroupId
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(revision, forKey: .revision)
      try container.encode(groupId, forKey: .groupId)
      try container.encode(acceptSignature, forKey: .acceptSignature)
      try container.encodeIfPresent(auditLogDetails, forKey: .auditLogDetails)
      try container.encodeIfPresent(autoAccept, forKey: .autoAccept)
      try container.encodeIfPresent(itemsForEmailing, forKey: .itemsForEmailing)
      try container.encodeIfPresent(userGroupId, forKey: .userGroupId)
    }
  }
}

extension UserDeviceAPIClient.SharingUserdevice.AcceptItemGroup {
  public typealias Response = ServerResponse
}
