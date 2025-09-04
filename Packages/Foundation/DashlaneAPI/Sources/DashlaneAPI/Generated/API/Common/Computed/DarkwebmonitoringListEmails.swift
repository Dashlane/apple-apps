import Foundation

public struct DarkwebmonitoringListEmails: Codable, Hashable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case email = "email"
    case state = "state"
    case expiresIn = "expiresIn"
  }

  public let email: String
  public let state: String
  public let expiresIn: Int?

  public init(email: String, state: String, expiresIn: Int? = nil) {
    self.email = email
    self.state = state
    self.expiresIn = expiresIn
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(email, forKey: .email)
    try container.encode(state, forKey: .state)
    try container.encodeIfPresent(expiresIn, forKey: .expiresIn)
  }
}
