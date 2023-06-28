import Foundation

public enum PlanDuration: String, Decodable {
    case yearly
    case monthly
}

public struct Offer: Decodable {
    public let planName: String
    public let duration: PlanDuration
    public let enabled: Bool

    public init(planName: String, duration: PlanDuration, enabled: Bool) {
        self.planName = planName
        self.duration = duration
        self.enabled = enabled
    }
}

public struct Offers: Decodable {
    public let freeOffers: OffersGroup
    public let essentialsOffers: OffersGroup
    public let premiumOffers: OffersGroup
    public let familyOffers: OffersGroup
    public let currentSubscription: String?
    public let purchaseToken: String?
}

public struct OffersGroup: Decodable {
    public let offers: [Offer]
    public let capabilities: OfferCapabilitySet
}

public extension Offer {

                var discountOfferIdentifier: String? {
        let planParts =  planName.components(separatedBy: ".")
        guard planParts.count == 2 else {
            return nil
        }
        return planParts.last
    }

                    var storeKitProductIdentifier: String? {
        return planName.components(separatedBy: ".").first
    }
}
