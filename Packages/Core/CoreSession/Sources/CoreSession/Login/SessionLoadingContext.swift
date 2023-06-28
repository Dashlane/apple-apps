import Foundation

public enum SessionLoadingContext {
    case accountCreation
    case localLogin(_ isRecoveryKeyUsed: Bool = false)
    case remoteLogin(_ isRecoveryKeyUsed: Bool = false)

    public var isFirstLogin: Bool {
        switch self {
        case .localLogin:
            return false
        case .accountCreation, .remoteLogin:
            return true
        }
    }

    public var isAccountRecoveryLogin: Bool {
        switch self {
        case let .localLogin(isRecoveryKeyUsed):
            return isRecoveryKeyUsed
        case let .remoteLogin(isRecoveryKeyUsed):
            return isRecoveryKeyUsed
        case .accountCreation:
            return false
        }
    }
}
