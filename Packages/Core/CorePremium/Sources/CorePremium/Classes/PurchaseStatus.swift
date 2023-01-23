import Foundation

public enum PurchaseStatus {
        case deferred
        case purchasing
        case verifyingReceipt
        case updatingPremiumStatus
        case success
        case error(Error)
}

extension PurchaseStatus {
    var isEnded: Bool {
        switch self {
            case .success, .error:
                return true
            default:
                return false
        }
    }
}
