import Foundation
import StoreKit

extension Bundle {
    static func receipt() throws -> Data {
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

struct ProductCategory {
    let offers: [Offer]
    let kind: PurchasePlan.Kind
    let capabilities: CapabilitySet
}

public extension Offers {
    var allOffers: [Offer] {
        return freeOffers.offers + premiumOffers.offers + essentialsOffers.offers + familyOffers.offers
    }
}

extension Offers {
    var allKindProducts: [ProductCategory] {
        [
            .init(offers: freeOffers.offers, kind: .free, capabilities: freeOffers.capabilities),
            .init(offers: essentialsOffers.offers, kind: .advanced, capabilities: essentialsOffers.capabilities),
            .init(offers: premiumOffers.offers, kind: .premium, capabilities: premiumOffers.capabilities),
            .init(offers: familyOffers.offers, kind: .family, capabilities: familyOffers.capabilities)
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

extension String {
    func first(nCharacters: Int) -> String {
        return String(self[..<self.index(self.startIndex, offsetBy: nCharacters)])
    }
}
