import Foundation

public struct PaymentsAccessibleStoreOffersInfo2: Codable, Hashable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case reason = "reason"
  }

  public let reason: PaymentsAccessibleStoreOffersReason?

  public init(reason: PaymentsAccessibleStoreOffersReason? = nil) {
    self.reason = reason
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(reason, forKey: .reason)
  }
}
