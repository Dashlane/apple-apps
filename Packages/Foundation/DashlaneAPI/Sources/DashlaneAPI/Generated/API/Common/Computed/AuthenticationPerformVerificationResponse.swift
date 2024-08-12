import Foundation

public struct AuthenticationPerformVerificationResponse: Codable, Equatable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case authTicket = "authTicket"
  }

  public let authTicket: String

  public init(authTicket: String) {
    self.authTicket = authTicket
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(authTicket, forKey: .authTicket)
  }
}
