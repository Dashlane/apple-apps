import Foundation
import DashlaneReportKit
import CorePersonalData
import CoreUserTracking

public extension VaultItem {
    var usageLogType: UsageLogCode11PersonalData.TypeType {
        switch enumerated {
        case .credential:
            return .authentication
        case .address:
            return .address
        case .bankAccount:
            return .bankStatement
        case .company:
            return .company
        case .creditCard:
            return .paymentMeanCreditcard
        case .drivingLicence:
            return .driverLicence
        case .email:
            return .email
        case .fiscalInformation:
            return .fiscal
        case .idCard:
            return .idCard
        case .identity:
            return .identity
        case .passport:
            return .passport
        case .personalWebsite:
            return .website
        case .phone:
            return .phone
        case .secureNote:
            return .note
        case .socialSecurityInformation:
            return .socialSecurity
        }
    }

    var usageLogType75: String {
       return XMLDataType(metadata.contentType).rawValue
    }
    
    var vaultItemType: Definition.ItemType {
        switch enumerated {
        case .credential:
            return .credential
        case .address:
            return .address
        case .bankAccount:
            return .bankStatement
        case .company:
            return .company
        case .creditCard:
            return .creditCard
        case .drivingLicence:
            return .driverLicence
        case .email:
            return .email
        case .fiscalInformation:
            return .fiscalStatement
        case .idCard:
            return .idCard
        case .identity:
            return .identity
        case .passport:
            return .passport
        case .personalWebsite:
            return .website
        case .phone:
            return .phone
        case .secureNote:
            return .secureNote
        case .socialSecurityInformation:
            return .socialSecurity
        }
    }
}

public enum UsageLog75SubType: String {
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
