import Foundation
import StoreKit
import DashTypes

extension DashlanePremiumManager {

                                    public func purchase(_ plan: PurchasePlan,
                         authenticatedAPIClient: DeprecatedCustomAPIClient,
                         completion handler: @escaping PurchaseHandler) {
        guard SKPaymentQueue.default().transactions.isEmpty else {
            handler(.error(DashlanePremiumManagerError.purchaseAlreadyStarted))
            return
        }
        guard plan.isDiscountedOffer == false else {
                                                purchaseDiscountedPlan(plan, authenticatedAPIClient: authenticatedAPIClient, completion: handler)
            return
        }
        do {
            currentPurchaseHandler = handler
            let payment = SKMutablePayment(product: plan.storeKitProduct)
            try processPayment(payment)
        } catch {
            handler(.error(error))
        }
    }

                            func purchase(_ plan: PurchasePlan,
                  payment: SKPayment,
                  authenticatedAPIClient: DeprecatedCustomAPIClient,
                  completion handler: @escaping PurchaseHandler) {
        guard SKPaymentQueue.default().transactions.isEmpty else {
            handler(.error(DashlanePremiumManagerError.purchaseAlreadyStarted))
            return
        }
        currentPurchaseHandler = handler
        SKPaymentQueue.default().add(payment)
    }

    @available(iOS 12.2, macOS 10.14.4, *)
                            func purchaseDiscountedPlan(
        _ discountedPlan: PurchasePlan,
        authenticatedAPIClient: DeprecatedCustomAPIClient,
        completion handler: @escaping PurchaseHandler
    ) {
        let signatureResponseHandler: (Result<SignatureResponse, Error>) -> Void = { result in
            switch result {
                case .success(let signature):
                    DashlanePremiumManager.shared.purchaseDiscountedPlan(discountedPlan,
                                                                         discountSignature: signature,
                                                                         completion: handler)
                case .failure(let error):
                    handler(.error(error))
            }
        }
        guard let applicationUsernameHash = self.currentSession?.applicationUsernameHash else {
            handler(.error(DashlanePremiumManagerError.currentSessionNotAvailable))
            return
        }

        guard let offerIdentifier = discountedPlan.storeKitProduct.discounts.first?.identifier else {
            handler(.error(DashlanePremiumManagerError.noDiscountAvailable(discountedPlan.offer.planName)))
            return
        }
        SignatureService.getSignature(appBundleID: "com.dashlane.dashlanephonefinal",
                                      productIdentifier: discountedPlan.storeKitProduct.productIdentifier,
                                      offerIdentifier: offerIdentifier,
                                      applicationUsername: applicationUsernameHash,
                                      authenticatedAPIClient: authenticatedAPIClient,
                                      completion: signatureResponseHandler)
    }

    @available(iOS 12.2, macOS 10.14.4, *)
                            private func purchaseDiscountedPlan(_ discountedProduct: PurchasePlan,
                                        discountSignature: SignatureResponse,
                                        completion handler: @escaping PurchaseHandler) {
        guard SKPaymentQueue.default().transactions.isEmpty else {
            handler(.error(DashlanePremiumManagerError.purchaseAlreadyStarted))
            return
        }
        guard let offerIdentifier = discountedProduct.offer.discountOfferIdentifier else {
            handler(.error(TransactionError.storeProductNotAvailable))
            return
        }
        guard let paymentDiscount = SKPaymentDiscount(signature: discountSignature, offerIdentifier: offerIdentifier) else {
            handler(.error(TransactionError.paymentInvalid))
            return
        }
        do {
            currentPurchaseHandler = handler
            let payment = SKMutablePayment(product: discountedProduct.storeKitProduct)
            payment.paymentDiscount = paymentDiscount
            try processPayment(payment)
        } catch {
            handler(.error(error))
        }
    }

                            private func processPayment(_ payment: SKMutablePayment) throws {
        guard let currentSession = currentSession else {
            throw TransactionError.sessionUnavailable
        }
        payment.applicationUsername = currentSession.applicationUsernameHash
        SKPaymentQueue.default().add(payment)
    }

                        func update(premiumStatus status: PremiumStatus, for login: String?) {
        guard let login = login else {
            return
        }
        self.delegate?.update(status, forLogin: login)
    }

                                internal func verifyReceipt(on transaction: SKPaymentTransaction, refreshReceiptOnFailure: Bool) throws {
                guard let service = verificationService else {
            throw DashlanePremiumManagerError.verificationServiceNotAvailable
        }
        let receiptData = try Bundle.receipt()
        let verifyHandler = verifyReceiptHandlerGenerator(on: transaction, refreshReceiptOnFailure: refreshReceiptOnFailure)
        service.verify(receiptData,
                       transactionId: transaction.transactionIdentifier!,
                       planName: planNameFrom(transaction),
                       regionCode: regionCodeFrom(transaction),
                       price: priceFrom(transaction)?.doubleValue,
                       currencyCode: currencyCodeFrom(transaction),
                       completion: verifyHandler)
    }

                            private func verifyReceiptHandlerGenerator(
        on transaction: SKPaymentTransaction,
        refreshReceiptOnFailure: Bool
    ) -> (Result<VerificationResult, Error>) -> Void {

        let handleSuccess: (VerificationResult) -> Void = { verificationResult in
                                    self.clearCache()

            if verificationResult.success {
                DispatchQueue.main.async {
                    self.notifyCurrentPurchaseHandler(.updatingPremiumStatus)
                }
                self.currentSession?.updatePremiumStatus { status, login in
                    self.update(premiumStatus: status, for: login)
                    DispatchQueue.main.async {
                        self.notifyCurrentPurchaseHandler(.success)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.notifyCurrentPurchaseHandler(.error(TransactionError.receiptInvalid))
                }
            }
            SKPaymentQueue.default().finishTransaction(transaction)
        }

        let handleError: (VerificationFailure) -> Void = { error in
            if case .receiptRefreshRequired = error, refreshReceiptOnFailure {
                let refreshRequest = ReceiptRefreshRequest { result in
                    switch result {
                    case .success:
                        do {
                            try self.verifyReceipt(on: transaction, refreshReceiptOnFailure: false)
                        } catch {
                            if transaction.transactionState == .purchased {
                                SKPaymentQueue.default().finishTransaction(transaction)
                            }
                        }
                    case .error(let error):
                        SKPaymentQueue.default().finishTransaction(transaction)
                        DispatchQueue.main.async {
                            self.notifyCurrentPurchaseHandler(.error(error))
                        }
                    }
                }
                self.receiptRefreshRequest = refreshRequest
                refreshRequest.start()
            } else {
                SKPaymentQueue.default().finishTransaction(transaction)
                DispatchQueue.main.async {
                    self.notifyCurrentPurchaseHandler(.error(error))
                }
            }
        }

        return { result in

            switch result {
            case .success(let verificationResult):
                handleSuccess(verificationResult)
            case .failure(let error as VerificationFailure):
                handleError(error)
            default:
                                                                                                break
            }
        }
    }

        private func clearCache() {
        purchasePlans = nil
        planOptions = nil
    }

                        public func verifyReceipt(verificationService: ReceiptVerificationService,
                              completion handler: RequestHandler<VerificationResult>? = nil) throws {
        let receiptData = try Bundle.receipt()
        verificationService.verify(receiptData, completion: { result in
            if let handler = handler {
                handler(result)
            }
        })
    }

                    internal func convertError(on transaction: SKPaymentTransaction) -> TransactionError {
        let errorTranslation: (NSError?) -> TransactionError = { error in
            guard let error = error else {
                return TransactionError.unknown
            }
            return TransactionError.convert(from: SKError(_nsError: error).code)
          }
        return errorTranslation(transaction.error as NSError?)
    }

                internal func canStartPendingPurchase() -> Bool {
        guard let session = currentSession else {
            return false
        }
        guard session.isBusinessUser == false else {
            return false
        }
        return true
    }

        func processPendingPurchase() {
        guard let pendingPurchase = self.pendingPurchase else {
            return
        }
        if canStartPendingPurchase() {
            SKPaymentQueue.default().add(pendingPurchase.payment)
            self.pendingPurchase = nil
        }
    }

        func notifyCurrentPurchaseHandler(_ status: PurchaseStatus) {
        currentPurchaseHandler?(status)
        if status.isEnded {
            currentPurchaseHandler = nil
        }
    }
}

public struct PlanOptions: OptionSet {
    static public let includeFamilyPlans = PlanOptions(rawValue: 1)
    static public let preferMonthly = PlanOptions(rawValue: 1 << 1)

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
