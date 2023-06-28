import Foundation
import StoreKit

public struct PurchasePlan {
    public enum Kind: Comparable {
        case free
        case essentials
        case advanced
        case premium
        case family
    }
    public let storeKitProduct: SKProduct
    public let offer: Offer
    public let kind: Kind
    public let capabilities: CapabilitySet
    public let isCurrentSubscription: Bool

    public init(storeKitProduct: SKProduct, offer: Offer, kind: PurchasePlan.Kind, capabilities: CapabilitySet, isCurrentSubscription: Bool) {
        self.storeKitProduct = storeKitProduct
        self.offer = offer
        self.kind = kind
        self.capabilities = capabilities
        self.isCurrentSubscription = isCurrentSubscription
    }
}

public extension PurchasePlan {
        var isDiscountedOffer: Bool {
        return offer.discountOfferIdentifier != nil
    }

        var isIntroductoryOffer: Bool {
        return storeKitProduct.introductoryPrice != nil
    }

                    var price: NSDecimalNumber {
        if let identifier = offer.discountOfferIdentifier, let discount = storeKitProduct.discount(with: identifier) {
            return discount.price
        } else if let introductoryPrice = storeKitProduct.introductoryPrice {
            return introductoryPrice.price
        } else {
            return storeKitProduct.price
        }
    }

    var nonDiscountedPrice: NSDecimalNumber {
        return storeKitProduct.price
    }

    var introductoryOfferNumberOfPeriod: Int? {
        return storeKitProduct.introductoryPrice?.numberOfPeriods
    }

    var introductoryOfferPeriod: SKProductSubscriptionPeriod? {
        return storeKitProduct.introductoryPrice?.subscriptionPeriod
    }

    var isPeriodIdenticalToIntroductoryOfferPeriod: Bool {
        return storeKitProduct.subscriptionPeriod?.unit == storeKitProduct.introductoryPrice?.subscriptionPeriod.unit
    }

    var introductoryOfferPaymentMode: SKProductDiscount.PaymentMode? {
        return storeKitProduct.introductoryPrice?.paymentMode
    }
}

extension SKProduct {
    func discount(with identifier: String) -> SKProductDiscount? {
        return self.discounts.first(where: { $0.identifier == identifier })
    }
}
