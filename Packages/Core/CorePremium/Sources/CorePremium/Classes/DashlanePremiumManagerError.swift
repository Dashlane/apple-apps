import Foundation

public enum DashlanePremiumManagerError: Error {
    case currentSessionNotAvailable
    case purchaseAlreadyStarted
    case receiptUnavailable
    case couldNotHashLogin
    case loginNotAvailable
    case verificationServiceNotAvailable
    case pendingPurchaseUnavailable
}
