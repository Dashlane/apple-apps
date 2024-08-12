import Foundation

extension Definition {

  public enum `WebcardItemType`: String, Encodable, Sendable {
    case `address`
    case `authentication`
    case `bankStatement` = "bank_statement"
    case `company`
    case `creditCard` = "credit_card"
    case `driverLicence` = "driver_licence"
    case `email`
    case `fiscalStatement` = "fiscal_statement"
    case `generatedPassword` = "generated_password"
    case `idCard` = "id_card"
    case `identity`
    case `nothing`
    case `passport`
    case `password`
    case `paypal`
    case `phone`
    case `socialSecurity` = "social_security"
    case `unknown`
    case `website`
  }
}
