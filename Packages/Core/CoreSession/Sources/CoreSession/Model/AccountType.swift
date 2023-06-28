import Foundation
import DashlaneAPI

public enum AccountType: Codable {
    case masterPassword
    case invisibleMasterPassword
    case sso
}

public extension AuthenticationGetMethodsAccountType {
    var userAccountType: AccountType {
        switch self {
        case .masterPassword:
            return .masterPassword
        case .invisibleMasterPassword:
            return .invisibleMasterPassword
        }
    }
}
