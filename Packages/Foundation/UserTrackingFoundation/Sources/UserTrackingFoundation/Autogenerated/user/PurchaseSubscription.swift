import Foundation

extension UserEvent {

  public struct `PurchaseSubscription`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `paymentAmount`: Int, `paymentCurrency`: Definition.PriceCurrencyCode,
      `paymentMethod`: Definition.PaymentMethod, `paymentStatus`: Definition.PaymentStatus,
      `purchasedPlan`: Definition.Plan, `purchasedSeatsCount`: Int
    ) {
      self.paymentAmount = paymentAmount
      self.paymentCurrency = paymentCurrency
      self.paymentMethod = paymentMethod
      self.paymentStatus = paymentStatus
      self.purchasedPlan = purchasedPlan
      self.purchasedSeatsCount = purchasedSeatsCount
    }
    public let name = "purchase_subscription"
    public let paymentAmount: Int
    public let paymentCurrency: Definition.PriceCurrencyCode
    public let paymentMethod: Definition.PaymentMethod
    public let paymentStatus: Definition.PaymentStatus
    public let purchasedPlan: Definition.Plan
    public let purchasedSeatsCount: Int
  }
}
