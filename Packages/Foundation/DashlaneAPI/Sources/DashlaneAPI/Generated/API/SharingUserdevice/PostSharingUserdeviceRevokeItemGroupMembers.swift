import Foundation

extension UserDeviceAPIClient.SharingUserdevice {
  public struct RevokeItemGroupMembers: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/sharing-userdevice/RevokeItemGroupMembers"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      revision: Int, groupId: String, auditLogDetails: AuditLogDetails? = nil,
      collections: [String]? = nil, groups: [String]? = nil, origin: Body.Origin? = nil,
      users: [String]? = nil, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(
        revision: revision, groupId: groupId, auditLogDetails: auditLogDetails,
        collections: collections, groups: groups, origin: origin, users: users)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var revokeItemGroupMembers: RevokeItemGroupMembers {
    RevokeItemGroupMembers(api: api)
  }
}

extension UserDeviceAPIClient.SharingUserdevice.RevokeItemGroupMembers {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case revision = "revision"
      case groupId = "groupId"
      case auditLogDetails = "auditLogDetails"
      case collections = "collections"
      case groups = "groups"
      case origin = "origin"
      case users = "users"
    }

    public enum Origin: String, Sendable, Hashable, Codable, CaseIterable {
      case autoInvalid = "auto_invalid"
      case manual = "manual"
      case undecodable
      public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Self(rawValue: rawValue) ?? .undecodable
      }
    }

    public let revision: Int
    public let groupId: String
    public let auditLogDetails: AuditLogDetails?
    public let collections: [String]?
    public let groups: [String]?
    public let origin: Origin?
    public let users: [String]?

    public init(
      revision: Int, groupId: String, auditLogDetails: AuditLogDetails? = nil,
      collections: [String]? = nil, groups: [String]? = nil, origin: Origin? = nil,
      users: [String]? = nil
    ) {
      self.revision = revision
      self.groupId = groupId
      self.auditLogDetails = auditLogDetails
      self.collections = collections
      self.groups = groups
      self.origin = origin
      self.users = users
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(revision, forKey: .revision)
      try container.encode(groupId, forKey: .groupId)
      try container.encodeIfPresent(auditLogDetails, forKey: .auditLogDetails)
      try container.encodeIfPresent(collections, forKey: .collections)
      try container.encodeIfPresent(groups, forKey: .groups)
      try container.encodeIfPresent(origin, forKey: .origin)
      try container.encodeIfPresent(users, forKey: .users)
    }
  }
}

extension UserDeviceAPIClient.SharingUserdevice.RevokeItemGroupMembers {
  public typealias Response = ServerResponse
}
