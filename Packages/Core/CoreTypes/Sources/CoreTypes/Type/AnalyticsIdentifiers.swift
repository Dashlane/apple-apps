import Foundation

public struct AnalyticsIdentifiers: Codable, Equatable, Sendable, Hashable {
  public let device: String
  public let user: String

  public init(device: String, user: String) {
    self.user = user
    self.device = device
  }
}
