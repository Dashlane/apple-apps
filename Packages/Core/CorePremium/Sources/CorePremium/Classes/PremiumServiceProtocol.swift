import Foundation
import Combine

public protocol PremiumServiceProtocol {
    var statusPublisher: Published<PremiumStatus?>.Publisher { get }
    var status: PremiumStatus? { get }
    var hasDiscountOffersPublisher: Published<Bool>.Publisher { get }

    var daysToExpiration: Int { get }
    var isAutoRenewing: Bool { get }
    var isExpired: Bool { get }
    var isExpiredRecently: Bool { get }

    func capability<T>(for keyPath: KeyPath<StatusCapabilitySet, Capability<T>>) -> Capability<T> where T: Decodable
    func capabilityPublisher<T>(for keyPath: KeyPath<StatusCapabilitySet, Capability<T>>) -> AnyPublisher<Capability<T>, Never> where T: Decodable
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

    public func capability<T>(for keyPath: KeyPath<StatusCapabilitySet, Capability<T>>) -> Capability<T> where T: Decodable {
        return status?.capabilities[keyPath: keyPath] ?? Capability(enabled: false, info: nil)
    }

    public func capabilityPublisher<T>(for keyPath: KeyPath<StatusCapabilitySet, Capability<T>>) -> AnyPublisher<Capability<T>, Never> where T: Decodable {
        return Just(capability(for: keyPath)).eraseToAnyPublisher()
    }
}
