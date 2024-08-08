import Foundation

public struct PaymentsAccessibleStoreOffersInfo2: Codable, Equatable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case reason = "reason"
  }

  public let reason: PaymentsAccessibleStoreOffersReason2?

  public init(reason: PaymentsAccessibleStoreOffersReason2? = nil) {
    self.reason = reason
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(reason, forKey: .reason)
  }
}
