import Foundation

public protocol PremiumServiceProtocol {
    var statusPublisher: Published<PremiumStatus?>.Publisher { get }
    var status: PremiumStatus? { get }
    var hasDiscountOffersPublisher: Published<Bool>.Publisher { get }

    var daysToExpiration: Int { get }
    var isAutoRenewing: Bool { get }
    var isExpired: Bool { get }
    var isExpiredRecently: Bool { get }
}

public class PremiumServiceMock: PremiumServiceProtocol {

    @Published
    public var status: PremiumStatus?

    @Published
    public var hasDiscountOffers: Bool

    public var statusPublisher: Published<PremiumStatus?>.Publisher { $status }
    public var hasDiscountOffersPublisher: Published<Bool>.Publisher { $hasDiscountOffers }

    public var daysToExpiration: Int = 10
    public var isAutoRenewing: Bool = true
    public var isExpired: Bool = false
    public var isExpiredRecently: Bool = false

    public init(status: PremiumStatus? = nil,
         hasDiscountOffers: Bool = false,
         daysToExpiration: Int = 10,
         isAutoRenewing: Bool = true,
         isExpired: Bool = false,
         isExpiredRecently: Bool = false) {
        self.status = status
        self.hasDiscountOffers = hasDiscountOffers
        self.daysToExpiration = daysToExpiration
        self.isAutoRenewing = isAutoRenewing
        self.isExpired = isExpired
        self.isExpiredRecently = isExpiredRecently
    }
}
