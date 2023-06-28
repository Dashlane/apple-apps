import Foundation
import DashTypes

public protocol PremiumSessionDelegate: AnyObject {

                        func premiumStatusData(for login: String) -> Data?

                        func setPremiumStatusData(_ data: Data?, for login: String)
}

public final class PremiumSession {

        public typealias PremiumStatusUpdateHandler = (PremiumStatus, String?) -> Void

        let login: String

        let applicationUsernameHash: String

        let webservice: LegacyWebService

        let dashlaneAPI: DeprecatedCustomAPIClient

        public private(set) var premiumStatus: PremiumStatus? {
        didSet {
            isBusinessUser = premiumStatus?.isBusinessUser()
        }
    }

        public private(set) var premiumStatusData: Data? {
        didSet {
            delegate?.setPremiumStatusData(premiumStatusData, for: login)
        }
    }

    public private(set) var offers: Offers?

    public private(set) var isBusinessUser: Bool?

    private weak var delegate: PremiumSessionDelegate?

    public init(for login: String,
                applicationUsernameHash: String,
                webservice: LegacyWebService,
                dashlaneAPI: DeprecatedCustomAPIClient,
                delegate: PremiumSessionDelegate) {
        self.login = login
        self.applicationUsernameHash = applicationUsernameHash
        self.dashlaneAPI = dashlaneAPI
        self.webservice = webservice
        self.delegate = delegate

                                self.premiumStatusData = delegate.premiumStatusData(for: login)
        if let data = self.premiumStatusData {
            self.premiumStatus = try? PremiumStatusService.decoder.decode(PremiumStatus.self, from: data)
        }
    }

                public func fetchOffers(includeFamilyPlans: Bool = true, preferMonthly: Bool = false, completion handler: ((Result<Offers, Error>) -> Void)? = nil) {
        guard self.offers == nil else {
            handler?(Result.success(offers!))
            return
        }

        let service = PremiumAccessibleOffersService(apiClient: dashlaneAPI)
        service.getOffers(includeFamilyPlans: includeFamilyPlans, preferMonthly: preferMonthly) { [weak self] result in
            switch result {
            case .success(let offers):
                self?.offers = offers
                handler?(Result.success(offers))
            case .failure(let error):
                handler?(Result.failure(error))
            }
        }
    }

        internal func updatePremiumStatus(completion handler: @escaping PremiumStatusUpdateHandler) {
        let service = PremiumStatusService(webservice: webservice)
        service.getStatus { [weak self] result in

            switch result {

            case .success(let (status, statusData)):
                self?.premiumStatus = status
                self?.premiumStatusData = statusData
                handler(status, self?.login)
            default:
                                                                break
            }
        }
    }
}

extension PremiumStatus {
    public func isBusinessUser() -> Bool {
        return spaces != nil
    }
}
