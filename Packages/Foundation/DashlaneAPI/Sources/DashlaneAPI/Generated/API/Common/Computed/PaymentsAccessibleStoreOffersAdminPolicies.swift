import Foundation

public struct PaymentsAccessibleStoreOffersAdminPolicies: Codable, Hashable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case enabled = "enabled"
    case info = "info"
  }

  public let enabled: Bool
  public let info: PaymentsAccessibleStoreOffersInfo?

  public init(enabled: Bool, info: PaymentsAccessibleStoreOffersInfo? = nil) {
    self.enabled = enabled
    self.info = info
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(enabled, forKey: .enabled)
    try container.encodeIfPresent(info, forKey: .info)
  }
}
