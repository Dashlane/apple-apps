import Foundation
import DashTypes
import StoreKit

public protocol DashlanePremiumManagerDelegate: AnyObject {
    func update(_ status: PremiumStatus, forLogin: String) -> Void
}

public final class DashlanePremiumManager: NSObject {
    
        public typealias RequestHandler<T> = (Result<T, Error>) -> Void
    
        public typealias PurchaseHandler = (PurchaseStatus) -> Void
    
    public typealias PurchasePlanListHandler = ([PurchasePlan]) -> Void

    public typealias PendingPurchaseHandler = (Bool) -> Void

    public typealias ProductIdentifier = String
    
        public static let shared = DashlanePremiumManager()
    
    public weak var delegate: DashlanePremiumManagerDelegate?
    
        private var productsRequest: SKProductsRequest?
    
        private var receiptRefreshRequest: ReceiptRefreshRequest?
    
        private var storeKitProductsRequestHandler: RequestHandler<[SKProduct]>?
    
        internal var currentPurchaseHandler: PurchaseHandler?
    
        public var verificationService: ReceiptVerificationService?
    
        public private(set) var products = [SKProduct]()

        var planOptions: PlanOptions?

        public private(set) var purchasePlans: [PurchasePlan]? {
        didSet {
            guard let purchasePlans = self.purchasePlans else {
                return
            }
            let localHandlers = purchasePlanListHandlers
            purchasePlanListHandlers.removeAll()
            localHandlers.forEach { handler in
                handler(purchasePlans)
            }
        }
    }
    
        public private(set) var invalidProductIdentifiers = [String]()
    
        public static let managementUrl = URL(string: "_")!
    
    private static let usernameHashMaxLength = 32
    
    private var purchasePlanListHandlers: [PurchasePlanListHandler] = []
    
        public var currentSession: PremiumSession? {
        didSet {
            if canStartPendingPurchase() {
                processPendingPurchase()
            }
        }
    }
    
        private var notificationObject: NSObjectProtocol? = nil

    private var pendingPurchaseHandlers: [PendingPurchaseHandler] = []

        internal var pendingPurchase: DirectStorePayment? = nil {
        didSet {
            notifyPendingPurchaseHandlers()
        }
    }
    
        public static func setup(forAppStore setupForAppStore: Bool = true) {
        if setupForAppStore {
                        SKPaymentQueue.default().add(DashlanePremiumManager.shared)
        }
    }
    
        private override init() {
        super.init()
    }

                        public func updateSessionWith(login: String,
                                  applicationUsernameHash: String,
                                  webservice: LegacyWebService,
                                  dashlaneAPI: DeprecatedCustomAPIClient,
                                  delegate: PremiumSessionDelegate) throws -> Void {

        var applicationUsernameHashFixed: String
        
        if applicationUsernameHash.count > DashlanePremiumManager.usernameHashMaxLength {
            applicationUsernameHashFixed = applicationUsernameHash.first(nCharacters: DashlanePremiumManager.usernameHashMaxLength)
        } else {
            applicationUsernameHashFixed = applicationUsernameHash
        }
        verificationService = ReceiptVerificationService(webservice: webservice)
        
        let session = PremiumSession(for: login,
                                     applicationUsernameHash: applicationUsernameHashFixed,
                                     webservice: webservice,
                                     dashlaneAPI: dashlaneAPI,
                                     delegate: delegate)
        self.currentSession = session
                self.fetchPurchasePlansForCurrentSession { _ in
            #if os(iOS)
            self.updateStoreProductVisibility()
            #endif
        }
                self.updatePremiumStatus()
    }
    
                public func updatePremiumStatus(completion handler: PremiumSession.PremiumStatusUpdateHandler? = nil) {
        currentSession?.updatePremiumStatus(completion: { status, login in
            self.update(premiumStatus: status, for: login)
            handler?(status, login)
        })
    }
    
    public func registerHandlerForPurchasePlan(_ handler: @escaping PurchasePlanListHandler) {
        guard let purchasePlans = purchasePlans else {
            self.purchasePlanListHandlers.append(handler)
            return
        }
        handler(purchasePlans)
    }
    
        public func endSession() -> Void {
        currentSession = nil
        purchasePlans = nil
    }
}

extension DashlanePremiumManager {

        public var pendingPurchaseWaitingForCompletion: Bool {
        return pendingPurchase != nil
    }

    public func registerHandlerForPendingPurchase(_ handler: @escaping PendingPurchaseHandler) {
        pendingPurchaseHandlers.append(handler)
        handler(self.pendingPurchase != nil)
    }

    public func notifyPendingPurchaseHandlers() {
        pendingPurchaseHandlers.forEach { handler in
            handler(self.pendingPurchase != nil)
        }
    }

    public func completePendingPurchase(authenticatedAPIClient: DeprecatedCustomAPIClient,
                                        completion handler: @escaping PurchaseHandler) {
        guard let pendingPurchase = pendingPurchase else {
                handler(.error(DashlanePremiumManagerError.pendingPurchaseUnavailable))
                return
        }
        pendingPurchaseAssociatedDashlanePremiumProduct { associatedDashlanePremiumProduct in
            guard let associatedDashlanePremiumProduct = associatedDashlanePremiumProduct else {
                handler(.error(DashlanePremiumManagerError.pendingPurchaseUnavailable))
                return
            }
            self.purchase(associatedDashlanePremiumProduct,
                     payment: pendingPurchase.payment,
                     authenticatedAPIClient: authenticatedAPIClient,
                     completion: handler)
        }
    }

    public func clearPendingPurchase() {
        pendingPurchase = nil
    }

        public func pendingPurchaseAssociatedDashlanePremiumProduct(includeFamilyPlans: Bool = true, completion handler: @escaping (PurchasePlan?) -> Void) {
        guard let pendingPurchaseProduct = pendingPurchase?.product else {
            handler(nil)
            return
        }
        DashlanePremiumManager.shared.currentSession?.fetchOffers(includeFamilyPlans: includeFamilyPlans, completion: { result in
            switch result {
            case .success(let offers):
                let products: [PurchasePlan] =  offers.allKindProducts.compactMap{ productCategory in
                    let purchasePlanBuilder = self.purchasePlanBuilder(for: productCategory.offers,  kind: productCategory.kind, capabilities: productCategory.capabilities, currentSubscription: offers.currentSubscription)
                    return purchasePlanBuilder(pendingPurchaseProduct)
                }
                
                handler(products.first)
            case .failure(_):
                handler(nil)
            }
        })
    }
}

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

                            private func purchase(_ plan: PurchasePlan,
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
                            private func purchaseDiscountedPlan(_ discountedPlan: PurchasePlan,
                                        authenticatedAPIClient: DeprecatedCustomAPIClient,
                                        completion handler: @escaping PurchaseHandler) {
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
        SignatureService.getSignature(appBundleID: "com.dashlane.dashlanephonefinal",
                                      productIdentifier: discountedPlan.storeKitProduct.productIdentifier,
                                      offerIdentifier: discountedPlan.storeKitProduct.discounts.first!.identifier!,
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
    
                        private func update(premiumStatus status: PremiumStatus, for login: String?) -> Void {
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
    
                        private func verifyReceiptHandlerGenerator(on transaction: SKPaymentTransaction,
                                               refreshReceiptOnFailure: Bool) -> (Result<VerificationResult, Error>) -> Void {
        
        let handleSuccess: (VerificationResult) -> Void = { verificationResult in
                                    self.clearCache()
            
            if verificationResult.success {
                DispatchQueue.main.async {
                    self.notifyCurrentPurchaseHandler(.updatingPremiumStatus)
                }
                self.currentSession?.updatePremiumStatus() { status, login in
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
                let refreshRequest = ReceiptRefreshRequest() { result in
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
    
        private func processPendingPurchase() {
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
    
    private func purchasePlanBuilder(for offers: [Offer], kind: PurchasePlan.Kind, capabilities: CapabilitySet, currentSubscription: String?) -> ((SKProduct) ->PurchasePlan?) {
    
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
                            let purchasePlanBuilder = self.purchasePlanBuilder(for: productCategory.offers,  kind: productCategory.kind, capabilities: productCategory.capabilities, currentSubscription: offers.currentSubscription)
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


extension DashlanePremiumManager {
    
    
                    private func areProductsAlreadyRequested(_ identifiers: [String]) -> Bool {
        let currentProductIds = Set(products.map { $0.productIdentifier })
        let requestedProductIds = Set(identifiers)
        return requestedProductIds.isSubset(of: currentProductIds)
    }
    
                    private func requestProducts(with identifiers: [String]) -> SKProductsRequest {
        let request = SKProductsRequest(productIdentifiers: Set(identifiers))
        request.delegate = self
        return request
    }
    
                    private func productFrom(_ transaction: SKPaymentTransaction) -> SKProduct? {
        guard let product = products.first(where: {
            transaction.payment.productIdentifier == $0.productIdentifier
        }) else {
            return nil
        }
        return product
    }
    
                    private func regionCodeFrom(_ transaction: SKPaymentTransaction) -> String? {
        guard let product = productFrom(transaction) else {
            return nil
        }
        return product.finalPriceLocale.regionCode
    }
    
    private func planNameFrom(_ transaction: SKPaymentTransaction) -> String {
        let productIdentifier = transaction.payment.productIdentifier
            
        if let discountIdentifier = transaction.payment.paymentDiscount?.identifier {
            return "\(productIdentifier).\(discountIdentifier)"
        }
        
        return productIdentifier
    }
    
                    private func priceFrom(_ transaction: SKPaymentTransaction) -> NSDecimalNumber? {
        guard let product = productFrom(transaction) else {
            return nil
        }
                                        if let discountIdentifier = transaction.discountIdentifier {
            guard let productDiscount = product.discount(with: discountIdentifier) else {
                return nil
            }
            return productDiscount.price
        }
        return product.finalPrice
    }
    
                    private func currencyCodeFrom(_ transaction: SKPaymentTransaction) -> String? {
        guard let product = productFrom(transaction) else {
            return nil
        }
        return product.finalPriceLocale.currencyCode
    }
}

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

extension Bundle {
    fileprivate static func receipt() throws -> Data {
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL else {
            throw DashlanePremiumManagerError.receiptUnavailable
        }
        return try Data(contentsOf: appStoreReceiptURL)
    }
}

extension PremiumStatus.StatusCode {
    var isStoreProductPromotionHidden: Bool {
        switch self {
        case .premium, .premiumRenewalStopped, .grace, .legacy:
                        return true
        default:
            return false
        }
    }
}

public extension Offers {
    var allOffers: [Offer] {
        return freeOffers.offers + premiumOffers.offers + essentialsOffers.offers + familyOffers.offers
    }

    var allKindProducts: [(offers: [Offer], kind: PurchasePlan.Kind, capabilities: CapabilitySet)] {
        return [
            (offers: freeOffers.offers, kind: .free, capabilities: freeOffers.capabilities),
            (offers: essentialsOffers.offers, kind: .advanced, capabilities: essentialsOffers.capabilities),
            (offers: premiumOffers.offers, kind: .premium, capabilities: premiumOffers.capabilities),
            (offers: familyOffers.offers, kind: .family, capabilities: familyOffers.capabilities)
        ]
    }
}

@available(iOS 12.2, macOS 10.14.4, *)
extension SKPaymentDiscount {
    convenience init?(signature: SignatureResponse, offerIdentifier: String) {
        guard let nonceUUID = UUID(uuidString: signature.nonce) else {
            return nil
        }
        guard let timestampValue = Int(signature.timestamp) else {
            return nil
        }
        let timestamp = NSNumber(integerLiteral: timestampValue)
        self.init(identifier: offerIdentifier,
                  keyIdentifier: signature.keyIdentifier,
                  nonce: nonceUUID,
                  signature: signature.signature,
                  timestamp: timestamp)
    }
}

@available(iOS 12.2, macOS 10.14.4, *)
extension SKPaymentTransaction {
    var discountIdentifier: String? {
        return self.payment.paymentDiscount?.identifier
    }
}

private extension String {
    func first(nCharacters: Int) -> String {
        return String(self[..<self.index(self.startIndex, offsetBy: nCharacters)])
    }
}
