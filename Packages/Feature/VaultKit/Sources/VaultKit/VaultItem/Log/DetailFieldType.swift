import Foundation
import CoreUserTracking

public enum DetailFieldType: String {
    case login
    case password
    case otp
    case cardNumber
    case cCNote
    case securityCode
    case bankAccountIBAN
    case bankAccountBIC
    case number
    case socialSecurityNumber
    case fiscalNumber
    case teledeclarantNumber
    case email
    case secondaryLogin
    case note
    case address
}

public extension DetailFieldType {
    
    var definitionField: Definition.Field {
        switch self {
        case .login:
            return .login
        case .password:
            return .password
        case .cardNumber:
            return .cardNumber
        case .securityCode:
            return .securityCode
        case .number:
            return .number
        case .socialSecurityNumber:
            return .socialSecurityNumber
        case .email:
            return .email
        case .bankAccountBIC:
            return .bic
        case .bankAccountIBAN:
            return .iban
        case .cCNote:
            return .note
        case .otp:
            return .otpSecret
        case .fiscalNumber:
            return .fiscalNumber
        case .teledeclarantNumber:
            return .teledeclarantNumber
        case .note:
            return .note
        case .secondaryLogin:
            return .secondaryLogin
        case .address:
            return .addressName
        }
    }
}
