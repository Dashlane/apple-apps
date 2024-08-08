import DashlaneAPI
import Foundation
import StoreKit

public struct PurchasePlan {
  public enum Kind: Comparable, Equatable {
    case free
    case essentials
    case advanced
    case premium
    case family
  }

  public let subscription: StoreKitSubscription
  public let offer: PaymentsAccessibleStoreOffers
  public let kind: Kind
  public let capabilities: PaymentsAccessibleStoreOffersCapabilities
  public let isCurrentSubscription: Bool

  public init(
    subscription: StoreKitSubscription,
    offer: PaymentsAccessibleStoreOffers,
    kind: PurchasePlan.Kind,
    capabilities: PaymentsAccessibleStoreOffersCapabilities,
    isCurrentSubscription: Bool
  ) {
    self.subscription = subscription
    self.offer = offer
    self.kind = kind
    self.capabilities = capabilities
    self.isCurrentSubscription = isCurrentSubscription
  }
}

extension PurchasePlan {
  public var isDiscountedOffer: Bool {
    return subscription.promotionalOffer != nil
  }

  public var appStoreDashlanePromoMismatch: Bool {
    return subscription.promotionalOffer == nil && offer.storeKitPromotionalOfferId != nil
  }

  public var isIntroductoryOffer: Bool {
    return subscription.introductoryOffer != nil
  }

  public var price: Decimal {
    if let promotionalOffer = subscription.promotionalOffer {
      return promotionalOffer.price
    } else if let introductoryOffer = subscription.introductoryOffer {
      return introductoryOffer.price
    } else {
      return subscription.price
    }
  }

  public var nonDiscountedPrice: Decimal {
    return subscription.price
  }

  public var introductoryOfferNumberOfPeriod: Int? {
    return subscription.introductoryOffer?.periodCount
  }

  public var introductoryOfferPeriod: StoreKitSubscription.Period? {
    return subscription.period
  }

  public var isPeriodIdenticalToIntroductoryOfferPeriod: Bool {
    return subscription.period == subscription.introductoryOffer?.period
  }

  public var introductoryOfferPaymentMode: Product.SubscriptionOffer.PaymentMode? {
    return subscription.introductoryOffer?.paymentMode
  }
}

extension PurchasePlan {
  public var localizedPrice: String {
    subscription.priceFormatStyle.format(price)
  }

  public var localizedNonDiscountedPrice: String {
    subscription.priceFormatStyle.format(nonDiscountedPrice)
  }
}

extension Product {
  func discount(with identifier: String) -> Product.SubscriptionOffer? {
    return self.subscription?.promotionalOffers.first { $0.id == identifier }
  }
}

extension Collection<PurchasePlan> {
  public func groupedByKind() -> [PurchasePlan.Kind: PlanTier] {
    return Dictionary(grouping: self, by: \.kind)
      .compactMapValues { plans -> PlanTier? in
        guard let first = plans.first else {
          return nil
        }
        return PlanTier(
          kind: first.kind,
          plans: plans,
          capabilities: first.capabilities)
      }
  }
}
