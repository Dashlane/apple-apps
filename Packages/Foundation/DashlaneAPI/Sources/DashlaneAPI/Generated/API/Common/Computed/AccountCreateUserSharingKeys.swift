import Foundation

public struct AccountCreateUserSharingKeys: Codable, Equatable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case privateKey = "privateKey"
    case publicKey = "publicKey"
  }

  public let privateKey: String
  public let publicKey: String

  public init(privateKey: String, publicKey: String) {
    self.privateKey = privateKey
    self.publicKey = publicKey
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(privateKey, forKey: .privateKey)
    try container.encode(publicKey, forKey: .publicKey)
  }
}
