import Foundation
import StoreKit

extension DashlanePremiumManager: SKProductsRequestDelegate {

    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        guard let productsRequestHandler = storeKitProductsRequestHandler else {
            return
        }
        self.products = response.products
        self.invalidProductIdentifiers.append(contentsOf: response.invalidProductIdentifiers)
        DispatchQueue.main.async {
            productsRequestHandler(.success(response.products))
        }
        storeKitProductsRequestHandler = nil
        self.productsRequest = nil
    }

    public func request(_ request: SKRequest, didFailWithError error: Error) {
        switch request {
        case productsRequest:
            guard let productsRequestHandler = storeKitProductsRequestHandler else {
                return
            }
            productsRequestHandler(.failure(error))
            storeKitProductsRequestHandler = nil
            self.productsRequest = nil
        case receiptRefreshRequest:

            self.receiptRefreshRequest = nil
        default:
                        break
        }
    }
}
