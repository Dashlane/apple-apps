import Foundation

public struct ItemGroupDownload: Codable, Equatable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case groupId = "groupId"
    case revision = "revision"
    case type = "type"
    case collections = "collections"
    case groups = "groups"
    case items = "items"
    case teamId = "teamId"
    case users = "users"
  }

  public enum `Type`: String, Sendable, Equatable, CaseIterable, Codable {
    case items = "items"
    case userGroupKeys = "userGroupKeys"
    case undecodable
    public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      let rawValue = try container.decode(String.self)
      self = Self(rawValue: rawValue) ?? .undecodable
    }
  }

  public struct CollectionsElement: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case uuid = "uuid"
      case name = "name"
      case permission = "permission"
      case status = "status"
      case acceptSignature = "acceptSignature"
      case itemGroupKey = "itemGroupKey"
      case proposeSignature = "proposeSignature"
      case referrer = "referrer"
    }

    public let uuid: String
    public let name: String
    public let permission: Permission
    public let status: Status
    public let acceptSignature: String?
    public let itemGroupKey: String?
    public let proposeSignature: String?
    public let referrer: String?

    public init(
      uuid: String, name: String, permission: Permission, status: Status,
      acceptSignature: String? = nil, itemGroupKey: String? = nil, proposeSignature: String? = nil,
      referrer: String? = nil
    ) {
      self.uuid = uuid
      self.name = name
      self.permission = permission
      self.status = status
      self.acceptSignature = acceptSignature
      self.itemGroupKey = itemGroupKey
      self.proposeSignature = proposeSignature
      self.referrer = referrer
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(uuid, forKey: .uuid)
      try container.encode(name, forKey: .name)
      try container.encode(permission, forKey: .permission)
      try container.encode(status, forKey: .status)
      try container.encodeIfPresent(acceptSignature, forKey: .acceptSignature)
      try container.encodeIfPresent(itemGroupKey, forKey: .itemGroupKey)
      try container.encodeIfPresent(proposeSignature, forKey: .proposeSignature)
      try container.encodeIfPresent(referrer, forKey: .referrer)
    }
  }

  public struct GroupsElement: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case groupId = "groupId"
      case name = "name"
      case permission = "permission"
      case status = "status"
      case acceptSignature = "acceptSignature"
      case groupKey = "groupKey"
      case proposeSignature = "proposeSignature"
      case referrer = "referrer"
    }

    public let groupId: String
    public let name: String
    public let permission: Permission
    public let status: Status
    public let acceptSignature: String?
    public let groupKey: String?
    public let proposeSignature: String?
    public let referrer: String?

    public init(
      groupId: String, name: String, permission: Permission, status: Status,
      acceptSignature: String? = nil, groupKey: String? = nil, proposeSignature: String? = nil,
      referrer: String? = nil
    ) {
      self.groupId = groupId
      self.name = name
      self.permission = permission
      self.status = status
      self.acceptSignature = acceptSignature
      self.groupKey = groupKey
      self.proposeSignature = proposeSignature
      self.referrer = referrer
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(groupId, forKey: .groupId)
      try container.encode(name, forKey: .name)
      try container.encode(permission, forKey: .permission)
      try container.encode(status, forKey: .status)
      try container.encodeIfPresent(acceptSignature, forKey: .acceptSignature)
      try container.encodeIfPresent(groupKey, forKey: .groupKey)
      try container.encodeIfPresent(proposeSignature, forKey: .proposeSignature)
      try container.encodeIfPresent(referrer, forKey: .referrer)
    }
  }

  public struct ItemsElement: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case itemId = "itemId"
      case itemKey = "itemKey"
    }

    public let itemId: String
    public let itemKey: String

    public init(itemId: String, itemKey: String) {
      self.itemId = itemId
      self.itemKey = itemKey
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(itemId, forKey: .itemId)
      try container.encode(itemKey, forKey: .itemKey)
    }
  }

  public let groupId: String
  public let revision: Int
  public let type: `Type`
  public let collections: [CollectionsElement]?
  public let groups: [GroupsElement]?
  public let items: [ItemsElement]?
  public let teamId: Int?
  public let users: [UserDownload]?

  public init(
    groupId: String, revision: Int, type: `Type`, collections: [CollectionsElement]? = nil,
    groups: [GroupsElement]? = nil, items: [ItemsElement]? = nil, teamId: Int? = nil,
    users: [UserDownload]? = nil
  ) {
    self.groupId = groupId
    self.revision = revision
    self.type = type
    self.collections = collections
    self.groups = groups
    self.items = items
    self.teamId = teamId
    self.users = users
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(groupId, forKey: .groupId)
    try container.encode(revision, forKey: .revision)
    try container.encode(type, forKey: .type)
    try container.encodeIfPresent(collections, forKey: .collections)
    try container.encodeIfPresent(groups, forKey: .groups)
    try container.encodeIfPresent(items, forKey: .items)
    try container.encodeIfPresent(teamId, forKey: .teamId)
    try container.encodeIfPresent(users, forKey: .users)
  }
}
