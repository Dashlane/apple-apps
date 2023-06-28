import Foundation

extension Definition {

public enum `ItemType`: String, Encodable {
case `address`
case `bankStatement` = "bank_statement"
case `company`
case `credential`
case `creditCard` = "credit_card"
case `driverLicence` = "driver_licence"
case `email`
case `fiscalStatement` = "fiscal_statement"
case `generatedPassword` = "generated_password"
case `idCard` = "id_card"
case `identity`
case `passkey`
case `passport`
case `paypal`
case `phone`
case `secureNote` = "secure_note"
case `securityBreach` = "security_breach"
case `socialSecurity` = "social_security"
case `website`
}
}