import Foundation

public struct PaymentsAccessibleStoreOffersInfo: Codable, Hashable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case excludedPolicies = "excludedPolicies"
    case reason = "reason"
  }

  public let excludedPolicies: [String]?
  public let reason: PaymentsAccessibleStoreOffersReason?

  public init(excludedPolicies: [String]? = nil, reason: PaymentsAccessibleStoreOffersReason? = nil)
  {
    self.excludedPolicies = excludedPolicies
    self.reason = reason
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(excludedPolicies, forKey: .excludedPolicies)
    try container.encodeIfPresent(reason, forKey: .reason)
  }
}
