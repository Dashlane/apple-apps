import Foundation

public enum DashlanePremiumManagerError: Error, LocalizedError {
    case currentSessionNotAvailable
    case purchaseAlreadyStarted
    case receiptUnavailable
    case couldNotHashLogin
    case verificationServiceNotAvailable
    case pendingPurchaseUnavailable
        case noDiscountAvailable(String)

    public var errorDescription: String? {
        switch self {
        case .currentSessionNotAvailable:
            return "No session available"
        case .purchaseAlreadyStarted:
            return "Already in a purchase process"
        case .receiptUnavailable:
            return "Receipt is not available"
        case .couldNotHashLogin:
            return "Could not hash login"
        case .verificationServiceNotAvailable:
            return "Verification service not instantiated"
        case .pendingPurchaseUnavailable:
            return "No pending purchase"
        case let .noDiscountAvailable(plan):
            return "No discount for plan \(plan)"
        }
    }
}
