import Foundation

public enum MaverickDataType: String, Codable {
    case email = "EMAIL"
    case credential = "AUTHENTIFIANT"
    case identity = "IDENTITY"
    case address = "ADDRESS"
    case phone = "PHONE"
    case company = "COMPANY"
    case website = "PERSONALWEBSITE"
    case idCard = "IDCARD"
    case passport = "PASSPORT"
    case driverLicence = "DRIVERLICENCE"
    case socialSecurity = "SOCIALSECURITYSTATEMENT"
    case fiscalStatement = "FISCALSTATEMENT"
    case paymentMeanCreditCard = "PAYMENTMEANS_CREDITCARD"
    case paymentMeanPaypal = "PAYMENTMEAN_PAYPAL"
    case bankStatement = "BANKSTATEMENT"
    case authCategory = "AUTH_CATEGORY"
    case generatedPassword = "GENERATED_PASSWORD"
}
