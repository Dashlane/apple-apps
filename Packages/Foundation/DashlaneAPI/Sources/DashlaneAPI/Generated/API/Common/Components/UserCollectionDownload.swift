import Foundation

public struct UserCollectionDownload: Codable, Equatable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case login = "login"
    case referrer = "referrer"
    case permission = "permission"
    case status = "status"
    case acceptSignature = "acceptSignature"
    case collectionKey = "collectionKey"
    case proposeSignature = "proposeSignature"
    case proposeSignatureUsingAlias = "proposeSignatureUsingAlias"
    case rsaStatus = "rsaStatus"
  }

  public enum RsaStatus: String, Sendable, Equatable, CaseIterable, Codable {
    case noKey = "noKey"
    case publicKey = "publicKey"
    case sharingKeys = "sharingKeys"
    case undecodable
    public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      let rawValue = try container.decode(String.self)
      self = Self(rawValue: rawValue) ?? .undecodable
    }
  }

  public let login: String
  public let referrer: String
  public let permission: Permission
  public let status: Status
  public let acceptSignature: String?
  public let collectionKey: String?
  public let proposeSignature: String?
  public let proposeSignatureUsingAlias: Bool?
  public let rsaStatus: RsaStatus?

  public init(
    login: String, referrer: String, permission: Permission, status: Status,
    acceptSignature: String? = nil, collectionKey: String? = nil, proposeSignature: String? = nil,
    proposeSignatureUsingAlias: Bool? = nil, rsaStatus: RsaStatus? = nil
  ) {
    self.login = login
    self.referrer = referrer
    self.permission = permission
    self.status = status
    self.acceptSignature = acceptSignature
    self.collectionKey = collectionKey
    self.proposeSignature = proposeSignature
    self.proposeSignatureUsingAlias = proposeSignatureUsingAlias
    self.rsaStatus = rsaStatus
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(login, forKey: .login)
    try container.encode(referrer, forKey: .referrer)
    try container.encode(permission, forKey: .permission)
    try container.encode(status, forKey: .status)
    try container.encodeIfPresent(acceptSignature, forKey: .acceptSignature)
    try container.encodeIfPresent(collectionKey, forKey: .collectionKey)
    try container.encodeIfPresent(proposeSignature, forKey: .proposeSignature)
    try container.encodeIfPresent(proposeSignatureUsingAlias, forKey: .proposeSignatureUsingAlias)
    try container.encodeIfPresent(rsaStatus, forKey: .rsaStatus)
  }
}
