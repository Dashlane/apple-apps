import Foundation
import DashTypes
import StoreKit

public protocol DashlanePremiumManagerDelegate: AnyObject {
    func update(_ status: PremiumStatus, forLogin: String)
}

public final class DashlanePremiumManager: NSObject {

        public typealias RequestHandler<T> = (Result<T, Error>) -> Void

        public typealias PurchaseHandler = (PurchaseStatus) -> Void

    public typealias PurchasePlanListHandler = ([PurchasePlan]) -> Void

    public typealias PendingPurchaseHandler = (Bool) -> Void

    public typealias ProductIdentifier = String

        public static let shared = DashlanePremiumManager()

    public weak var delegate: DashlanePremiumManagerDelegate?

        var productsRequest: SKProductsRequest?

        var receiptRefreshRequest: ReceiptRefreshRequest?

        var storeKitProductsRequestHandler: RequestHandler<[SKProduct]>?

        internal var currentPurchaseHandler: PurchaseHandler?

        public var verificationService: ReceiptVerificationService?

        public internal(set) var products = [SKProduct]()

        var planOptions: PlanOptions?

        public internal(set) var purchasePlans: [PurchasePlan]? {
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

        public internal(set) var invalidProductIdentifiers = [String]()

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

        private var notificationObject: NSObjectProtocol?

    private var pendingPurchaseHandlers: [PendingPurchaseHandler] = []

        internal var pendingPurchase: DirectStorePayment? {
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
                                  delegate: PremiumSessionDelegate) throws {

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

        public func endSession() {
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
                let products: [PurchasePlan] =  offers.allKindProducts.compactMap { productCategory in
                    let purchasePlanBuilder = self.purchasePlanBuilder(for: productCategory.offers, kind: productCategory.kind, capabilities: productCategory.capabilities, currentSubscription: offers.currentSubscription)
                    return purchasePlanBuilder(pendingPurchaseProduct)
                }

                handler(products.first)
            case .failure:
                handler(nil)
            }
        })
    }
}

extension DashlanePremiumManager {

                    func areProductsAlreadyRequested(_ identifiers: [String]) -> Bool {
        let currentProductIds = Set(products.map { $0.productIdentifier })
        let requestedProductIds = Set(identifiers)
        return requestedProductIds.isSubset(of: currentProductIds)
    }

                    func requestProducts(with identifiers: [String]) -> SKProductsRequest {
        let request = SKProductsRequest(productIdentifiers: Set(identifiers))
        request.delegate = self
        return request
    }

                    func productFrom(_ transaction: SKPaymentTransaction) -> SKProduct? {
        guard let product = products.first(where: {
            transaction.payment.productIdentifier == $0.productIdentifier
        }) else {
            return nil
        }
        return product
    }

                    func regionCodeFrom(_ transaction: SKPaymentTransaction) -> String? {
        guard let product = productFrom(transaction) else {
            return nil
        }
        return product.finalPriceLocale.language.region?.identifier
    }

    func planNameFrom(_ transaction: SKPaymentTransaction) -> String {
        let productIdentifier = transaction.payment.productIdentifier

        if let discountIdentifier = transaction.payment.paymentDiscount?.identifier {
            return "\(productIdentifier).\(discountIdentifier)"
        }

        return productIdentifier
    }

                    func priceFrom(_ transaction: SKPaymentTransaction) -> NSDecimalNumber? {
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

                    func currencyCodeFrom(_ transaction: SKPaymentTransaction) -> String? {
        guard let product = productFrom(transaction) else {
            return nil
        }
        return product.finalPriceLocale.currency?.identifier
    }
}
