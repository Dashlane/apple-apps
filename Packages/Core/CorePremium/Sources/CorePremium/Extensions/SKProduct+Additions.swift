import Foundation
import StoreKit

extension SKProduct {
    public var finalPrice: NSDecimalNumber {
        guard let introductoryPrice = self.introductoryPrice else {
            return self.price
        }
        return introductoryPrice.price
    }
    
    public var finalPriceLocale: Locale {
        guard let introductoryPrice = self.introductoryPrice else {
            return self.priceLocale
        }
        return introductoryPrice.priceLocale
    }
}
