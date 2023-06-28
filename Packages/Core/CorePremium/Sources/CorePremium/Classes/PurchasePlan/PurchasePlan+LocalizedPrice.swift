import Foundation
import StoreKit

public extension PurchasePlan {
    func makePriceFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        formatter.locale = storeKitProduct.priceLocale
        formatter.currencyCode = storeKitProduct.priceLocale.currency?.identifier

        return formatter
    }

    var localizedPrice: String {
        let formatter = makePriceFormatter()
        return formatter.string(from: self.price)!
    }

    var localizedNonDiscountedPrice: String {
        let formatter = makePriceFormatter()
        return formatter.string(from: self.nonDiscountedPrice)!
    }
}

public extension PlanTier {
    var localizedYearlyDiscount: String {
        guard let plan = plans.first else {
            return ""
        }
        let formatter = plan.makePriceFormatter()
        return formatter.string(from: NSNumber(value: self.yearlyDiscount))!
    }
}
