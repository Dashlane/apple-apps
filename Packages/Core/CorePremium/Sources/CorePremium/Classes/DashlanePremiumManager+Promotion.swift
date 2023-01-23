#if os(iOS)
import Foundation
import StoreKit

extension DashlanePremiumManager {
    
            internal func updateStoreProductVisibility() {
        guard let offers = self.currentSession?.offers else {
            return
        }

        let allProductIds = offers.allOffers.map({ $0.planName })

        guard !allProductIds.isEmpty else {
            return
        }
        guard let activeProducts = self.currentSession?.offers?.premiumOffers else {
            return
        }
        guard let statusCode = self.currentSession?.premiumStatus?.statusCode else {
            return
        }
        let promotionController = SKProductStorePromotionController.default()
        let activeProductIds = activeProducts.offers.map { $0.planName }
        let visibilityForProduct: (SKProduct) -> SKProductStorePromotionVisibility = { product in
            if statusCode.isStoreProductPromotionHidden {
                return .hide
            }
            return activeProductIds.contains(product.productIdentifier) ? .show : .hide
        }
        let updateVisibilityForProduct: (SKProduct) -> Void = { product in
            promotionController.update(storePromotionVisibility: visibilityForProduct(product),
                                       for: product, completionHandler: nil)
        }
        self.fetchProducts(with: allProductIds, handler: { result in
            switch result {
            case .success(let products):
                products.forEach(updateVisibilityForProduct)
            default:
                                break
            }
        })
    }
}

#endif
