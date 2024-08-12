import Foundation

public struct TeamsProposeMembersV2PlanDetails: Codable, Equatable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case currency = "currency"
    case duration = "duration"
    case name = "name"
    case planType = "planType"
    case priceRanges = "priceRanges"
    case tier = "tier"
    case isSiteLicense = "isSiteLicense"
    case siteLicenseFullPrice = "siteLicenseFullPrice"
  }

  public let currency: String
  public let duration: String
  public let name: String
  public let planType: String
  public let priceRanges: [TeamsProposeMembersV2PriceRanges]
  public let tier: TeamsProposeMembersV2Tier
  public let isSiteLicense: Bool
  public let siteLicenseFullPrice: Int?

  public init(
    currency: String, duration: String, name: String, planType: String,
    priceRanges: [TeamsProposeMembersV2PriceRanges], tier: TeamsProposeMembersV2Tier,
    isSiteLicense: Bool, siteLicenseFullPrice: Int? = nil
  ) {
    self.currency = currency
    self.duration = duration
    self.name = name
    self.planType = planType
    self.priceRanges = priceRanges
    self.tier = tier
    self.isSiteLicense = isSiteLicense
    self.siteLicenseFullPrice = siteLicenseFullPrice
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(currency, forKey: .currency)
    try container.encode(duration, forKey: .duration)
    try container.encode(name, forKey: .name)
    try container.encode(planType, forKey: .planType)
    try container.encode(priceRanges, forKey: .priceRanges)
    try container.encode(tier, forKey: .tier)
    try container.encode(isSiteLicense, forKey: .isSiteLicense)
    try container.encodeIfPresent(siteLicenseFullPrice, forKey: .siteLicenseFullPrice)
  }
}
