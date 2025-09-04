import Foundation

public struct PaymentsAccessibleStoreOffers2: Codable, Hashable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case offers = "offers"
    case capabilities = "capabilities"
  }

  public let offers: [PaymentsAccessibleStoreOffers]
  public let capabilities: PaymentsAccessibleStoreOffersCapabilities

  public init(
    offers: [PaymentsAccessibleStoreOffers], capabilities: PaymentsAccessibleStoreOffersCapabilities
  ) {
    self.offers = offers
    self.capabilities = capabilities
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(offers, forKey: .offers)
    try container.encode(capabilities, forKey: .capabilities)
  }
}
