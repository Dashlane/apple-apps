import Foundation
import StoreKit

public struct StoreKitSubscription {
  public struct Period: Equatable {
    public let unit: Product.SubscriptionPeriod.Unit
    public let value: Int

    public init(unit: Product.SubscriptionPeriod.Unit, value: Int) {
      self.unit = unit
      self.value = value
    }
  }

  public struct Offer: Equatable {
    public let id: String?
    public let period: Period
    public let periodCount: Int
    public let paymentMode: Product.SubscriptionOffer.PaymentMode
    public let price: Decimal

    public init(
      id: String?, period: Period, periodCount: Int,
      paymentMode: Product.SubscriptionOffer.PaymentMode, price: Decimal
    ) {
      self.id = id
      self.period = period
      self.periodCount = periodCount
      self.paymentMode = paymentMode
      self.price = price
    }
  }

  public let id: Product.ID
  public let price: Decimal
  public let period: Period
  public let promotionalOffer: Offer?
  public let introductoryOffer: Offer?

  public let priceFormatStyle: Decimal.FormatStyle.Currency
  public let purchaseAction:
    (_ options: Set<Product.PurchaseOption>) async throws -> Product.PurchaseResult

  public init(
    id: Product.ID,
    price: Decimal,
    period: Period = .init(unit: .year, value: 1),
    promotionalOffer: Offer? = nil,
    introductoryOffer: Offer? = nil,
    priceFormatStyle: Decimal.FormatStyle.Currency = .currency(code: "USA"),
    purchaseAction: @escaping (_: Set<Product.PurchaseOption>) -> Product.PurchaseResult
  ) {
    self.id = id
    self.price = price
    self.period = period
    self.promotionalOffer = promotionalOffer
    self.introductoryOffer = introductoryOffer
    self.priceFormatStyle = priceFormatStyle
    self.purchaseAction = purchaseAction
  }

  public func purchase(options: Set<Product.PurchaseOption> = []) async throws
    -> Product.PurchaseResult
  {
    try await purchaseAction(options)
  }
}

extension StoreKitSubscription {
  public init?(product: Product, promotionalOfferIdentifier: String?) {
    guard let subscription = product.subscription else {
      return nil
    }

    self.id = product.id
    self.price = product.price
    self.period = .init(subscription.subscriptionPeriod)

    self.promotionalOffer =
      if let promotionalOfferIdentifier,
        let offer = subscription.promotionalOffers.first(withId: promotionalOfferIdentifier)
      {
        Offer(offer)
      } else {
        nil
      }

    self.introductoryOffer =
      if let offer = subscription.introductoryOffer {
        Offer(offer)
      } else {
        nil
      }

    self.priceFormatStyle = product.priceFormatStyle
    self.purchaseAction = product.purchase
  }

}

#if os(visionOS)
  extension Product {
    func purchase(options: Set<Product.PurchaseOption>) async throws -> Product.PurchaseResult {
      guard let first = await UIApplication.shared.connectedScenes.first else {
        return .userCancelled
      }

      return try await purchase(confirmIn: first, options: options)
    }
  }
#endif

extension StoreKitSubscription.Offer {
  init(_ offer: Product.SubscriptionOffer) {
    id = offer.id
    period = .init(offer.period)
    periodCount = offer.periodCount
    paymentMode = offer.paymentMode
    price = offer.price
  }
}

extension StoreKitSubscription.Period {
  init(_ period: Product.SubscriptionPeriod) {
    self.unit = period.unit
    self.value = period.value
  }
}

extension [Product.SubscriptionOffer] {
  func first(withId identifier: String) -> Product.SubscriptionOffer? {
    return first { $0.id == identifier }
  }
}
