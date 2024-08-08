import Foundation

public struct ServerResponse: Codable, Equatable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case collections = "collections"
    case itemErrors = "itemErrors"
    case itemGroupErrors = "itemGroupErrors"
    case itemGroups = "itemGroups"
    case items = "items"
    case sharingVersion = "sharingVersion"
    case userGroupErrors = "userGroupErrors"
    case userGroups = "userGroups"
  }

  public let collections: [CollectionDownload]?
  public let itemErrors: [ItemError]?
  public let itemGroupErrors: [ItemGroupError]?
  public let itemGroups: [ItemGroupDownload]?
  public let items: [ItemContent]?
  public let sharingVersion: Int?
  public let userGroupErrors: [UserGroupError]?
  public let userGroups: [UserGroupDownload]?

  public init(
    collections: [CollectionDownload]? = nil, itemErrors: [ItemError]? = nil,
    itemGroupErrors: [ItemGroupError]? = nil, itemGroups: [ItemGroupDownload]? = nil,
    items: [ItemContent]? = nil, sharingVersion: Int? = nil,
    userGroupErrors: [UserGroupError]? = nil, userGroups: [UserGroupDownload]? = nil
  ) {
    self.collections = collections
    self.itemErrors = itemErrors
    self.itemGroupErrors = itemGroupErrors
    self.itemGroups = itemGroups
    self.items = items
    self.sharingVersion = sharingVersion
    self.userGroupErrors = userGroupErrors
    self.userGroups = userGroups
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(collections, forKey: .collections)
    try container.encodeIfPresent(itemErrors, forKey: .itemErrors)
    try container.encodeIfPresent(itemGroupErrors, forKey: .itemGroupErrors)
    try container.encodeIfPresent(itemGroups, forKey: .itemGroups)
    try container.encodeIfPresent(items, forKey: .items)
    try container.encodeIfPresent(sharingVersion, forKey: .sharingVersion)
    try container.encodeIfPresent(userGroupErrors, forKey: .userGroupErrors)
    try container.encodeIfPresent(userGroups, forKey: .userGroups)
  }
}
