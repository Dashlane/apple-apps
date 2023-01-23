import UIKit
import DashTypes
import CoreNetworking
import CorePremium
import StoreKit


class ViewController: UIViewController, PremiumSessionDelegate {

    @IBOutlet var textView: UITextView!
    
    var discountProduct: SKProductDiscount?
    
    let dashlaneAPI = LegacyWebServiceImpl(logger: Log())
    let webservice = LegacyWebServiceImpl(logger: Log())
    
    static var appCredentials: AppCredentials {
        return AppCredentials(accessKey: ApplicationSecrets.Server.apiKey,
                              secretKey: ApplicationSecrets.Server.apiSecret)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DashlanePremiumManager.shared.registerHandlerForPurchasePlan { products in
            self.log(products.description)
        }
        
                dashlaneAPI.configureAuthentication(method: .signatureBased(appCredentials: ViewController.appCredentials, userCredentials: TestAccount.userCredentials))
        
                try! DashlanePremiumManager.shared.updateSessionWith(login: TestAccount.login,
                                                             applicationUsernameHash: TestAccount.hashedAccountName,
                                                             webservice: webservice,
                                                             dashlaneAPI: dashlaneAPI,
                                                             delegate: self)
        
                webservice.configureAuthentication(usingLogin: TestAccount.login, uki: TestAccount.uki)
        
                let receiptService = ReceiptVerificationService(webservice: webservice)
        DashlanePremiumManager.shared.verificationService = receiptService
        
                fetchProducts(handler: fetchProductsResponse)
    }

        func signatureResponse(result: Result<SignatureResponse, Error>) -> Void {
        self.log("Signature fetched.")

        switch result {
            case .success(let signatureResponse):
                self.log(signatureResponse.debugDescription)
                self.log("Purchasing product...")
                DashlanePremiumManager.shared.purchase(DashlanePremiumManager.shared.purchasePlans!.first!,
                                                       authenticatedAPIClient: dashlaneAPI,
                                                       completion: { status in
                                                        self.log(String(describing: status))
                                                       })
            case .failure(let error):
                self.log(error.localizedDescription)
        }
    }

    func log(_ text: String) {
        DispatchQueue.main.async {
            self.textView.appendText(text)
        }
    }
    
        func fetchSignatureWithProducts(_ products: [SKProduct]) {
        self.log("Fetching signature...")
        
        SignatureService.getSignature(appBundleID: "com.dashlane.dashlanephonefinal",
                                      productIdentifier: products.first!.productIdentifier,
                                      offerIdentifier: self.discountProduct!.identifier!,
                                      applicationUsername: TestAccount.hashedAccountName,
                                      authenticatedAPIClient: self.dashlaneAPI,
                                      completion: signatureResponse)
    }
    
        func fetchProductsResponse(result: Result<[SKProduct], Error>) -> Void {
        log("Products fetched.")
        
        switch result {
        case .success(let products):
            self.log(products.debugDescription)
            self.discountProduct = products.first?.discounts.first
            self.fetchSignatureWithProducts(products)
        case .failure(let failure):
            self.log(failure.localizedDescription)
        }
    }

        func fetchProducts(handler: @escaping (Result<[SKProduct], Error>) -> Void) {
        log("Fetching products...")
        
        DashlanePremiumManager.shared.fetchPurchasePlansForCurrentSession { _ in
            DashlanePremiumManager.shared.fetchProducts(with: ["IOSAutoYearlyA"], handler: handler)
        }
    }

    func purchaseDiscountedProduct() -> Void {
        self.log("Purchasing product...")
        DashlanePremiumManager.shared.purchase(DashlanePremiumManager.shared.purchasePlans!.first!,
                                               authenticatedAPIClient: self.dashlaneAPI,
                                               completion: { status in
                                                self.log(String(describing: status))
        })
    }

    
    func premiumStatusData(for login: String) -> Data? {
        print("premiumStatusData called")
        return nil
    }
    
    func setPremiumStatusData(_ data: Data?, for login: String) {
        print("setPremiumStatusData called")
    }
}


extension UITextView {
    func appendText(_ text: String) {
        self.text += "\(text)\n\n"
    }
    func clear() {
        self.text = ""
    }
}


struct TestAccount {
    static let login = "_"
    static let hashedAccountName = "QUM0NERGQTlDNjQwQTU3OTUQUM0NERGQTlDNjQwQTU3OTUQUM0NERGQTlDNjQwQTU3OTU"
    static let uki = "9E8B5DC3C2564604938FA1BF92114D92-9C12728F-75B6-49CE-AE04-48A4B05BC587"
    static let deviceId = "9E8B5DC3C2564604938FA1BF92114D92"
    static let userCredentials: UserCredentials = UserCredentials(login: TestAccount.login, deviceAccessKey: TestAccount.deviceId, deviceSecretKey: TestAccount.uki)
}

struct Log: Logger {
    
    func fatal(_ message: @escaping () -> String, location: Location) {
        print(message(), location)
    }
    func error(_ message: @escaping () -> String, location: Location) {
        print(message(), location)
    }
    func warning(_ message: @escaping () -> String, location: Location) {
        print(message(), location)
    }
    func info(_ message: @escaping () -> String, location: Location) {
        print(message(), location)
    }
    
    func debug(_ message: @escaping () -> String, location: Location) {
        print(message(), location)
    }
    
    func sublogger(for identifier: LoggerIdentifier) -> Logger {
        return self
    }
}

extension SKProduct {
    override open var debugDescription: String {
        return """
            \(super.debugDescription)
            discounts: \(self.discounts.map { $0.debugDescription }.joined(separator: "\n"))
            """
    }
}
extension SKProductDiscount {
    override open var debugDescription: String {
        return """
            \(super.debugDescription)
            identifier: \(self.identifier!)
            number of periods: \(self.numberOfPeriods)
            payment mode: \(self.paymentMode)
            price: \(self.price)
            price locale: (self.priceLocale)
            subsciption period: \(self.subscriptionPeriod.debugDescription)
            """
    }
}

extension SKProductDiscount.PaymentMode: CustomDebugStringConvertible {
    public var debugDescription: String {
        
        switch self {
        case .freeTrial:
            return "free trial"
        case .payAsYouGo:
            return "pay as you go"
        case .payUpFront:
            return "pay up front"
        @unknown default:
            return "unknown"
        }
    }
}

extension SKProductSubscriptionPeriod {
    open override var debugDescription: String {
        switch self.unit {
        case .day:
            return "\(self.numberOfUnits) day(s)"
        case .month:
            return "\(self.numberOfUnits) month(s)"
        case .week:
            return "\(self.numberOfUnits) week(s)"
        case .year:
            return "\(self.numberOfUnits) year(s)"
        default:
            return "unkonwn"
        }
    }
}

extension SignatureResponse: CustomDebugStringConvertible {
    public var debugDescription: String {
        return """
            keyIdentifier: \(self.keyIdentifier)
            nonce: \(self.nonce)
            signature: \(self.signature)
            signatureLength: \(self.signature.count)
            timestamp: \(self.timestamp)
            """
    }
}

struct ReceiptVerificationServiceParser: ResponseParserProtocol {
    
    func parse(data: Data) throws -> VerificationResult {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        do {
            let result = try decoder.decode(VerificationResult.self, from: data)
            return result
        } catch {
            let result: VerificationError
            do {
                result = try decoder.decode(VerificationError.self, from: data)
            } catch {
                throw VerificationFailure.unknown
            }

            if result.refreshReceipt {
                throw VerificationFailure.receiptRefreshRequired(reason: result.type == .emptyReceipt ? .emptyReceipt : nil)
            } else {
                throw VerificationFailure.unknown
            }
        }
    }
}
