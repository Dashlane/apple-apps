import Foundation
import StoreKit

public enum TransactionError: Error {
    case clientInvalid
    case paymentCancelled
    case paymentInvalid
    case paymentNotAllowed
    case storeProductNotAllowed
    case storeProductNotAvailable
    case cloudServicePermissionDenied
    case cloudServiceNetworkConnectionFailed
    case cloudServiceRevoked
    case receiptInvalid
    case unknown
    case sessionUnavailable

    public var code: Int {
        switch self {
        case .clientInvalid:
            return 1001
        case .paymentCancelled:
            return 1002
        case .paymentInvalid:
            return 1003
        case .paymentNotAllowed:
            return 1004
        case .storeProductNotAllowed:
            return 1005
        case .storeProductNotAvailable:
            return 1006
        case .cloudServicePermissionDenied:
            return 1007
        case .cloudServiceNetworkConnectionFailed:
            return 1008
        case .cloudServiceRevoked:
            return 1009
        case .receiptInvalid:
            return 1010
        default:
            return 1020
        }
    }
}
