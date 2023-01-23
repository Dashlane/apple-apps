import Combine
import CorePremium
import DashTypes
import CoreSession
import DashlaneCrypto
import DashlaneAppKit
import LoginKit
import SwiftTreats
import Foundation
#if canImport(UIKit)
import UIKit
#endif

class PremiumService: Mockable {
    let manager = DashlanePremiumManager.shared
    var logger: Logger
    let session: Session

        private let userEncryptedSettings: UserEncryptedSettings
    private let webservice: LegacyWebService
    private let dashlaneAPI: DeprecatedCustomAPIClient
    private let usageLogService: UsageLogServiceProtocol
    private var receiptVerificationService: ReceiptVerificationService
    private var cancellable: AnyCancellable?
    private var premiumNotificationService: PremiumNotificationService?
    private let communicationCenter = AppExtensionCommunicationCenter(channel: .fromApp)

        @Published
    public var status: PremiumStatus? 
    @Published
    var latestStatusFromServer: PremiumStatus? 

    @Published
    var hasDiscountOffers: Bool = false

        var isPremiumUser: Bool {
        guard let status = status else {
            return false
        }
        return status.isPremiumUser
    }

    var availableOffers: [Offer] {
        guard let offers = manager.currentSession?.offers else {
            return []
        }

        return offers.allOffers
    }

    public var premiumStatusPublisher: AnyPublisher<PremiumStatus?, Never> {
        return $status.eraseToAnyPublisher()
    }

    private init(session: Session,
                 userEncryptedSettings: UserEncryptedSettings,
                 webservice: LegacyWebService,
                 dashlaneAPI: DeprecatedCustomAPIClient,
                 logger: Logger,
                 usageLogService: UsageLogServiceProtocol) throws {
        self.session = session
        self.logger = logger
        self.usageLogService = usageLogService
        self.webservice = webservice
        self.dashlaneAPI = dashlaneAPI
        self.userEncryptedSettings = userEncryptedSettings
        self.receiptVerificationService = ReceiptVerificationService(webservice: webservice)
        self.manager.delegate = self
        try configure()
        self.status = manager.currentSession?.premiumStatus
        setupPremiumWillExpireNotification()
    }

    static func setup() {
        DashlanePremiumManager.setup(forAppStore: true)
    }

    private func configure() throws {
        setupNotifications()
        updatePremiumSession()
        verifyReceiptIfNeeded()
        updateDiscountOffers()
    }

    private func logPremium() {
        guard let status = status else { return }
        let usageLogger = PremiumStatusUsageLogger(usageLogService: usageLogService)
        usageLogger.sendPremiumLogs(for: status)
    }

    func setupPremiumWillExpireNotification() {
        guard self.isPremiumUser,
            !self.isAutoRenewing,
            status?.isBusinessAccount == false,
            status?.isFamilyInvitee == false else {
                premiumNotificationService?.clearAllNotifications()
                self.premiumNotificationService = nil
                return
        }
        if self.premiumNotificationService == nil {
            self.premiumNotificationService = PremiumNotificationService(login: session.login.email,
                                                                         premiumService: self)
        }
    }

    private func updateDiscountOffers() {
        guard let products = manager.purchasePlans else {
            hasDiscountOffers = false
            manager.registerHandlerForPurchasePlan(didReceive)
            return
        }
        let discountedProduct = products.first { $0.isDiscountedOffer }
        hasDiscountOffers = discountedProduct != nil
    }

    private func didReceive(plans: [PurchasePlan]) {
        let discountedProduct = plans.first { $0.isDiscountedOffer }
        hasDiscountOffers = discountedProduct != nil
    }

        private func setupNotifications() {
        #if os(iOS)
        cancellable = NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification).sink { [weak self] _ in
            self?.manager.updatePremiumStatus()
        }
        #endif
    }

    private func updatePremiumSession() {
        do {
            manager.verificationService = self.receiptVerificationService
            manager.endSession()
                        try manager.updateSessionWith(login: session.login.email,
                                          applicationUsernameHash: session.login.email.applicationUsernameHash(),
                                          webservice: webservice,
                                          dashlaneAPI: dashlaneAPI,
                                          delegate: self)
                        manager.fetchPurchasePlansForCurrentSession(handler: nil)
        } catch {
            fatalError("Session update must not fail")
        }
    }

                private func verifyReceiptIfNeeded() {
        let storedHash: Data? = userEncryptedSettings[.receiptHash]
        guard let receiptHash = Bundle.receiptHash,
            receiptHash != storedHash else {
            return
        }

                                        try? manager.verifyReceipt(verificationService: self.receiptVerificationService, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let verificationResult) where verificationResult.success:
                self.userEncryptedSettings[.receiptHash] = receiptHash
            case .failure(let error):
                                                if case let VerificationFailure.receiptRefreshRequired(reason) = error, reason == .emptyReceipt {
                    self.userEncryptedSettings[.receiptHash] = receiptHash
                }
            default:
                                break
            }
        })
    }

    func unload(reason: SessionServicesUnloadReason) {
        self.manager.delegate = nil
        self.manager.endSession()
    }
}

extension PremiumStatus {
        var isPremiumUser: Bool {
        return [PremiumStatus.StatusCode.premium, PremiumStatus.StatusCode.premiumRenewalStopped].contains(statusCode)
    }
}

extension PremiumService: DashlanePremiumManagerDelegate {
    func update(_ newStatus: PremiumStatus, forLogin: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.status = newStatus
            let newStatusIsDifferent = newStatus.statusCode != self.latestStatusFromServer?.statusCode
            self.latestStatusFromServer = newStatus

            self.setupPremiumWillExpireNotification()
            self.logger.info("Premium Status Available: \(String(describing: newStatus.planName))")
            self.logPremium()

                        if newStatusIsDifferent {
                self.communicationCenter.write(message: .premiumStatusDidUpdate)
            }
        }
    }

}

extension PremiumService {

    convenience init(session: Session,
                     userEncryptedSettings: UserEncryptedSettings,
                     legacyWebService: LegacyWebService,
                     apiClient: DeprecatedCustomAPIClient,
                     logger: Logger,
                     usageLogService: UsageLogService) async throws {
        try self.init(session: session,
                      userEncryptedSettings: userEncryptedSettings,
                      webservice: legacyWebService,
                      dashlaneAPI: apiClient,
                      logger: logger,
                      usageLogService: usageLogService)
        _ = try await self.$status
            .filter { $0 != nil }
            .timeout(.seconds(10), scheduler: DispatchQueue.main)
            .values
            .first()
            .unwrapped
    }
}

extension PremiumService: PremiumSessionDelegate {
    func premiumStatusData(for login: String) -> Data? {
        return userEncryptedSettings[.premiumStatusData]
    }

    func setPremiumStatusData(_ data: Data?, for login: String) {
        userEncryptedSettings[.premiumStatusData] = data
    }
}

extension String {
                        func applicationUsernameHash() throws -> String {
        guard let hash = SHA.hash(text: self, using: PseudoRandomAlgorithm.sha512) else {
            throw DashlanePremiumManagerError.couldNotHashLogin
        }
        return hash.base64EncodedString()
    }
}

private extension Bundle {
    static var receiptHash: Data? {
        guard let receiptURL = Bundle.main.appStoreReceiptURL else {
            return nil
        }
        guard let data = try? Data(contentsOf: receiptURL) else {
            return nil
        }
        return SHA.hash(data: data, using: .sha256)
    }
}

extension PremiumService {
     public var isPremiumFamily: Bool {
        guard let status = status else { return false }
        guard let offers = manager.currentSession?.offers else { return false }
        guard let premiumFamilyOffer = offers.familyOffers.offers.first(where: { $0.duration == .yearly }) else {
            return false
        }
        return premiumFamilyOffer.planName == status.planName
    }
}

extension PremiumService {
    var isAutoRenewing: Bool {
        guard let autoRenewal = status?.autoRenewal else {
            return false
        }
        return autoRenewal
    }

    var isExpired: Bool {
        guard let statusCode = status?.statusCode else {
            return false
        }
        return statusCode == .free
    }

    var isExpiredRecently: Bool {
        return isExpired && (0...15).contains(daysSinceExpiration)
    }

    var daysSinceExpiration: Int {
        guard let endDate = status?.actualPreviousPlan?.endDate else {
            return 0
        }
        let calendar = NSCalendar.current
        let today = calendar.startOfDay(for: Date())
        let premiumExpiry = calendar.startOfDay(for: endDate)
        let components = calendar.dateComponents([.day], from: premiumExpiry, to: today)
        guard let days = components.day else {
            return 0
        }
        return days
    }

    var daysToExpiration: Int {
        return status?.daysToExpiration() ?? 0
    }
}

extension PremiumService: CorePremium.PremiumServiceProtocol {
    var statusPublisher: Published<CorePremium.PremiumStatus?>.Publisher {
        $status
    }

    var hasDiscountOffersPublisher: Published<Bool>.Publisher {
        $hasDiscountOffers
    }

}
