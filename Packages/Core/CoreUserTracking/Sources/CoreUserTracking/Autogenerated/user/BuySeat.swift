import Foundation

extension UserEvent {

  public struct `BuySeat`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `errorCheckout`: Definition.ErrorCheckout? = nil, `flowStep`: Definition.FlowStep,
      `hasPromo`: Bool, `initialSeatCount`: Int, `priceAmountCents`: Int,
      `priceCurrencyCode`: Definition.PriceCurrencyCode, `purchasedSeatCount`: Int
    ) {
      self.errorCheckout = errorCheckout
      self.flowStep = flowStep
      self.hasPromo = hasPromo
      self.initialSeatCount = initialSeatCount
      self.priceAmountCents = priceAmountCents
      self.priceCurrencyCode = priceCurrencyCode
      self.purchasedSeatCount = purchasedSeatCount
    }
    public let errorCheckout: Definition.ErrorCheckout?
    public let flowStep: Definition.FlowStep
    public let hasPromo: Bool
    public let initialSeatCount: Int
    public let name = "buy_seat"
    public let priceAmountCents: Int
    public let priceCurrencyCode: Definition.PriceCurrencyCode
    public let purchasedSeatCount: Int
  }
}
