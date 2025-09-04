import Foundation

public struct UserInviteResend: Codable, Hashable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case userId = "userId"
    case alias = "alias"
  }

  public let userId: String
  public let alias: String

  public init(userId: String, alias: String) {
    self.userId = userId
    self.alias = alias
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(userId, forKey: .userId)
    try container.encode(alias, forKey: .alias)
  }
}
