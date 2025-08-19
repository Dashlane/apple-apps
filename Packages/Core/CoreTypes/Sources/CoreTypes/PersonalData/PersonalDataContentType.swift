import Foundation
import LogFoundation

@Loggable
public enum PersonalDataContentType: String, Codable, Hashable, CaseIterable {
  case address = "ADDRESS"
  case bankAccount = "BANKSTATEMENT"
  case company = "COMPANY"
  case collection = "COLLECTION"
  case credential = "AUTHENTIFIANT"
  case credentialCategory = "AUTH_CATEGORY"
  case creditCard = "PAYMENTMEANS_CREDITCARD"
  case dataChangeHistory = "DATA_CHANGE_HISTORY"
  case driverLicence = "DRIVERLICENCE"
  case email = "EMAIL"
  case generatedPassword = "GENERATED_PASSWORD"
  case idCard = "IDCARD"
  case identity = "IDENTITY"
  case passport = "PASSPORT"
  case phone = "PHONE"
  case secureFileInfo = "SECUREFILEINFO"
  case secureNote = "SECURENOTE"
  case secret = "SECRET"
  case secureNoteCategory = "SECURENOTE_CATEGORY"
  case securityBreach = "SECURITYBREACH"
  case settings = "SETTINGS"
  case socialSecurityInfo = "SOCIALSECURITYSTATEMENT"
  case taxNumber = "FISCALSTATEMENT"
  case website = "PERSONALWEBSITE"
  case passkey = "PASSKEY"
  case wifi = "WIFI"
}

extension PersonalDataContentType {
  public var canBeEmbeddedInCollection: Bool {
    switch self {
    case .credential, .secureNote:
      return true
    default:
      return false
    }
  }
}
