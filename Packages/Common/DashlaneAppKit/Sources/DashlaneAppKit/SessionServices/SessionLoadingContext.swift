import Foundation

public enum SessionLoadingContext {
    case accountCreation
    case localLogin
    case remoteLogin
    
    public var isFirstLogin: Bool {
        switch self {
        case .localLogin:
            return false
        case .accountCreation, .remoteLogin:
            return true
        }
    }
}
