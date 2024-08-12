import Foundation

public struct TeamsProposeMembersV2PriceRanges: Codable, Equatable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case startMembers = "startMembers"
    case price = "price"
    case equivalentPrice = "equivalentPrice"
    case priceEur = "priceEur"
    case equivalentPriceEur = "equivalentPriceEur"
    case b2bPlanId = "b2bPlanId"
  }

  public let startMembers: Int
  public let price: Int
  public let equivalentPrice: Int
  public let priceEur: Int
  public let equivalentPriceEur: Int
  public let b2bPlanId: Int?

  public init(
    startMembers: Int, price: Int, equivalentPrice: Int, priceEur: Int, equivalentPriceEur: Int,
    b2bPlanId: Int? = nil
  ) {
    self.startMembers = startMembers
    self.price = price
    self.equivalentPrice = equivalentPrice
    self.priceEur = priceEur
    self.equivalentPriceEur = equivalentPriceEur
    self.b2bPlanId = b2bPlanId
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(startMembers, forKey: .startMembers)
    try container.encode(price, forKey: .price)
    try container.encode(equivalentPrice, forKey: .equivalentPrice)
    try container.encode(priceEur, forKey: .priceEur)
    try container.encode(equivalentPriceEur, forKey: .equivalentPriceEur)
    try container.encodeIfPresent(b2bPlanId, forKey: .b2bPlanId)
  }
}
