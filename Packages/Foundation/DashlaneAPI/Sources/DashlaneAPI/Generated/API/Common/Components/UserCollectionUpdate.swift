import Foundation

public struct UserCollectionUpdate: Codable, Hashable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case login = "login"
    case collectionKey = "collectionKey"
    case permission = "permission"
    case proposeSignature = "proposeSignature"
  }

  public let login: String
  public let collectionKey: String?
  public let permission: Permission?
  public let proposeSignature: String?

  public init(
    login: String, collectionKey: String? = nil, permission: Permission? = nil,
    proposeSignature: String? = nil
  ) {
    self.login = login
    self.collectionKey = collectionKey
    self.permission = permission
    self.proposeSignature = proposeSignature
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(login, forKey: .login)
    try container.encodeIfPresent(collectionKey, forKey: .collectionKey)
    try container.encodeIfPresent(permission, forKey: .permission)
    try container.encodeIfPresent(proposeSignature, forKey: .proposeSignature)
  }
}
