import Foundation
import StoreKit

#if os(iOS)

extension TransactionError {
    static func convert(from code: SKError.Code) -> TransactionError {
        switch code {
        case SKError.clientInvalid:
            return .clientInvalid
        case SKError.paymentCancelled:
            return .paymentCancelled
        case SKError.cloudServiceNetworkConnectionFailed:
            return .cloudServiceNetworkConnectionFailed
        case SKError.cloudServicePermissionDenied:
            return .cloudServicePermissionDenied
        case SKError.cloudServiceRevoked:
            return .cloudServiceRevoked
        case SKError.paymentInvalid:
            return .paymentInvalid
        case SKError.paymentNotAllowed:
            return .paymentNotAllowed
        case SKError.storeProductNotAvailable:
            return .storeProductNotAvailable
        default:
            return .unknown
        }
    }
}

#else

extension TransactionError {
    static func convert(from code: SKError.Code) -> TransactionError {
        switch code {
        case SKError.clientInvalid:
            return .clientInvalid
        case SKError.paymentCancelled:
            return .paymentCancelled
        case SKError.paymentInvalid:
            return .paymentInvalid
        case SKError.paymentNotAllowed:
            return .paymentNotAllowed
        default:
            return .unknown
        }
    }
}

#endif
