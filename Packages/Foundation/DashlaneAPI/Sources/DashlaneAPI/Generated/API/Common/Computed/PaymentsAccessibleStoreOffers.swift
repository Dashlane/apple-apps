import Foundation

public struct PaymentsAccessibleStoreOffers: Codable, Hashable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case planName = "planName"
    case duration = "duration"
    case enabled = "enabled"
    case mode = "mode"
  }

  public let planName: String
  public let duration: PaymentsAccessibleStoreOffersDuration
  public let enabled: Bool?
  public let mode: PaymentsAccessibleStoreOffersMode?

  public init(
    planName: String, duration: PaymentsAccessibleStoreOffersDuration, enabled: Bool? = nil,
    mode: PaymentsAccessibleStoreOffersMode? = nil
  ) {
    self.planName = planName
    self.duration = duration
    self.enabled = enabled
    self.mode = mode
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(planName, forKey: .planName)
    try container.encode(duration, forKey: .duration)
    try container.encodeIfPresent(enabled, forKey: .enabled)
    try container.encodeIfPresent(mode, forKey: .mode)
  }
}
