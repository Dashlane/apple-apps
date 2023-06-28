import Foundation
import StoreKit

extension DashlanePremiumManager {
                        public func fetchProducts(with identifiers: [String], handler: RequestHandler<[SKProduct]>?) {
        guard areProductsAlreadyRequested(identifiers) == false else {
            let relevantProducts = products.filter { identifiers.contains($0.productIdentifier) }
            DispatchQueue.main.async {
                handler?(.success(relevantProducts))
            }
            return
        }
                cancelRequests()
        let request = requestProducts(with: identifiers)
        if let currentHandler = self.storeKitProductsRequestHandler {
            let newHandler: RequestHandler<[SKProduct]> = { result in
                DispatchQueue.main.async {
                    currentHandler(result)
                    handler?(result)
                }
            }
            self.storeKitProductsRequestHandler = newHandler
        } else {
            self.storeKitProductsRequestHandler = handler
        }
        self.productsRequest = request
        request.start()
    }

    func purchasePlanBuilder(for offers: [Offer], kind: PurchasePlan.Kind, capabilities: CapabilitySet, currentSubscription: String?) -> ((SKProduct) -> PurchasePlan?) {

        return { product in
            guard let offer = offers.first(where: { offer in
                offer.storeKitProductIdentifier == product.productIdentifier
            }) else {
                return nil
            }
            let isCurrentSubscription = offer.storeKitProductIdentifier == currentSubscription
            return PurchasePlan(storeKitProduct: product, offer: offer, kind: kind, capabilities: capabilities, isCurrentSubscription: isCurrentSubscription)
        }
    }

                        public func fetchPurchasePlansForCurrentSession(using options: PlanOptions = [.includeFamilyPlans], handler: RequestHandler<[PurchasePlan]>? = nil) {
        guard let currentSession = currentSession else {
            handler?(.failure(DashlanePremiumManagerError.currentSessionNotAvailable))
            return
        }

        let hasSameOptionsAsCache = (planOptions == options)
                guard self.purchasePlans == nil || !hasSameOptionsAsCache else {
            handler?(.success(self.purchasePlans!))
            return
        }

        currentSession.fetchOffers(includeFamilyPlans: options.contains(.includeFamilyPlans), preferMonthly: options.contains(.preferMonthly)) { [weak self] result in
            switch result {
            case .success(let offers):
                let productIdentifiers = offers.allOffers.compactMap { $0.storeKitProductIdentifier }
                self?.fetchProducts(with: productIdentifiers, handler: { result in
                    switch result {
                    case .success(let storeKitProducts):
                        guard let self = self else { return }
                        self.planOptions = options
                        self.purchasePlans = []
                        offers.allKindProducts.forEach { productCategory in
                            let purchasePlanBuilder = self.purchasePlanBuilder(for: productCategory.offers, kind: productCategory.kind, capabilities: productCategory.capabilities, currentSubscription: offers.currentSubscription)
                            let plans = storeKitProducts.compactMap(purchasePlanBuilder)
                            self.purchasePlans?.append(contentsOf: plans)
                        }
                        handler?(.success((self.purchasePlans!)))
                    case .failure(let error):
                        handler?(.failure(error))
                    }
                })
            case .failure(let error):
                handler?(.failure(error))
            }
        }
    }

        public func cancelRequests() {
        self.productsRequest?.cancel()
    }
}
