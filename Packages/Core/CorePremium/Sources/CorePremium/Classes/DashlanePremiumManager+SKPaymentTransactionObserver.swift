import Foundation
import StoreKit

extension DashlanePremiumManager: SKPaymentTransactionObserver {

    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { transaction in
            switch transaction.transactionState {
            case .failed:
                queue.finishTransaction(transaction)
                DispatchQueue.main.async {
                    self.notifyCurrentPurchaseHandler(.error(self.convertError(on: transaction)))
                }
            case .purchased:
                                                                DispatchQueue.main.async {
                    self.notifyCurrentPurchaseHandler(.verifyingReceipt)
                }
                do {
                                                            try verifyReceipt(on: transaction, refreshReceiptOnFailure: true)
                } catch {
                    SKPaymentQueue.default().finishTransaction(transaction)
                    DispatchQueue.main.async {
                        self.notifyCurrentPurchaseHandler(.error(error))
                    }
                }
            case .purchasing:
                                                                DispatchQueue.main.async {
                    self.notifyCurrentPurchaseHandler(.purchasing)
                }
            case .deferred:
                                                                DispatchQueue.main.async {
                    self.notifyCurrentPurchaseHandler(.deferred)
                }
            case .restored:
                                                                break
            @unknown default:
                break
            }
        }
    }

        #if os(iOS)
    public func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        self.pendingPurchase = DirectStorePayment(product: product, payment: payment)
                        return false
    }
    #endif
}
