import Foundation

public struct UserGroupDownload: Codable, Hashable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case groupId = "groupId"
    case name = "name"
    case type = "type"
    case publicKey = "publicKey"
    case privateKey = "privateKey"
    case revision = "revision"
    case users = "users"
    case externalId = "externalId"
    case familyId = "familyId"
    case teamId = "teamId"
  }

  public enum `Type`: String, Sendable, Hashable, Codable, CaseIterable {
    case users = "users"
    case teamAdmins = "teamAdmins"
    case undecodable
    public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      let rawValue = try container.decode(String.self)
      self = Self(rawValue: rawValue) ?? .undecodable
    }
  }

  public let groupId: String
  public let name: String
  public let type: `Type`
  public let publicKey: String
  public let privateKey: String
  public let revision: Int
  public let users: [UserDownload]
  public let externalId: String?
  public let familyId: Int?
  public let teamId: Int?

  public init(
    groupId: String, name: String, type: `Type`, publicKey: String, privateKey: String,
    revision: Int, users: [UserDownload], externalId: String? = nil, familyId: Int? = nil,
    teamId: Int? = nil
  ) {
    self.groupId = groupId
    self.name = name
    self.type = type
    self.publicKey = publicKey
    self.privateKey = privateKey
    self.revision = revision
    self.users = users
    self.externalId = externalId
    self.familyId = familyId
    self.teamId = teamId
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(groupId, forKey: .groupId)
    try container.encode(name, forKey: .name)
    try container.encode(type, forKey: .type)
    try container.encode(publicKey, forKey: .publicKey)
    try container.encode(privateKey, forKey: .privateKey)
    try container.encode(revision, forKey: .revision)
    try container.encode(users, forKey: .users)
    try container.encodeIfPresent(externalId, forKey: .externalId)
    try container.encodeIfPresent(familyId, forKey: .familyId)
    try container.encodeIfPresent(teamId, forKey: .teamId)
  }
}
