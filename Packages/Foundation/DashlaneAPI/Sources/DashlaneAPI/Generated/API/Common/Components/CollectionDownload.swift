import Foundation

public struct CollectionDownload: Codable, Equatable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case uuid = "uuid"
    case name = "name"
    case revision = "revision"
    case publicKey = "publicKey"
    case privateKey = "privateKey"
    case authorLogin = "authorLogin"
    case userGroups = "userGroups"
    case users = "users"
  }

  public let uuid: String
  public let name: String
  public let revision: Int
  public let publicKey: String
  public let privateKey: String
  public let authorLogin: String?
  public let userGroups: [UserGroupCollectionDownload]?
  public let users: [UserCollectionDownload]?

  public init(
    uuid: String, name: String, revision: Int, publicKey: String, privateKey: String,
    authorLogin: String? = nil, userGroups: [UserGroupCollectionDownload]? = nil,
    users: [UserCollectionDownload]? = nil
  ) {
    self.uuid = uuid
    self.name = name
    self.revision = revision
    self.publicKey = publicKey
    self.privateKey = privateKey
    self.authorLogin = authorLogin
    self.userGroups = userGroups
    self.users = users
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(uuid, forKey: .uuid)
    try container.encode(name, forKey: .name)
    try container.encode(revision, forKey: .revision)
    try container.encode(publicKey, forKey: .publicKey)
    try container.encode(privateKey, forKey: .privateKey)
    try container.encodeIfPresent(authorLogin, forKey: .authorLogin)
    try container.encodeIfPresent(userGroups, forKey: .userGroups)
    try container.encodeIfPresent(users, forKey: .users)
  }
}
