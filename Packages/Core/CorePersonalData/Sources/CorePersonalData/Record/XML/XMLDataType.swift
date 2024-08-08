import DashTypes
import Foundation

public enum XMLDataType: String, Codable, Hashable {
  case address = "KWAddress"
  case bankAccount = "KWBankStatement"
  case collection = "KWCollection"
  case company = "KWCompany"
  case credential = "KWAuthentifiant"
  case credentialCategory = "KWAuthCategory"
  case creditCard = "KWPaymentMean_creditCard"
  case dataChangeHistory = "KWDataChangeHistory"
  case dataChangeSets = "KWChangeSet"
  case driverLicence = "KWDriverLicence"
  case email = "KWEmail"
  case generatedPassword = "KWGeneratedPassword"
  case idCard = "KWIDCard"
  case identity = "KWIdentity"
  case passport = "KWPassport"
  case phone = "KWPhone"
  case secureFileInfo = "KWSecureFileInfo"
  case secret = "KWSecret"
  case secureNote = "KWSecureNote"
  case secureNoteCategory = "KWSecureNoteCategory"
  case securityBreach = "KWSecurityBreach"
  case settings = "KWSettingsManagerApp"
  case socialSecurityInfo = "KWSocialSecurityStatement"
  case taxNumber = "KWFiscalStatement"
  case website = "KWPersonalWebsite"
  case passkey = "KWPasskey"
}

extension XMLDataType {
  public init(_ contentType: PersonalDataContentType) {
    switch contentType {
    case .address:
      self = .address
    case .bankAccount:
      self = .bankAccount
    case .collection:
      self = .collection
    case .company:
      self = .company
    case .credential:
      self = .credential
    case .credentialCategory:
      self = .credentialCategory
    case .creditCard:
      self = .creditCard
    case .dataChangeHistory:
      self = .dataChangeHistory
    case .driverLicence:
      self = .driverLicence
    case .email:
      self = .email
    case .generatedPassword:
      self = .generatedPassword
    case .idCard:
      self = .idCard
    case .identity:
      self = .identity
    case .passport:
      self = .passport
    case .phone:
      self = .phone
    case .secureFileInfo:
      self = .secureFileInfo
    case .secureNote:
      self = .secureNote
    case .secureNoteCategory:
      self = .secureNoteCategory
    case .securityBreach:
      self = .securityBreach
    case .settings:
      self = .settings
    case .socialSecurityInfo:
      self = .socialSecurityInfo
    case .taxNumber:
      self = .taxNumber
    case .website:
      self = .website
    case .passkey:
      self = .passkey
    case .secret:
      self = .secret
    }
  }
}
extension PersonalDataContentType {
  init?(xmlDataType: XMLDataType) {
    switch xmlDataType {
    case .address:
      self = .address
    case .bankAccount:
      self = .bankAccount
    case .collection:
      self = .collection
    case .company:
      self = .company
    case .credential:
      self = .credential
    case .credentialCategory:
      self = .credentialCategory
    case .creditCard:
      self = .creditCard
    case .dataChangeHistory:
      self = .dataChangeHistory
    case .driverLicence:
      self = .driverLicence
    case .email:
      self = .email
    case .generatedPassword:
      self = .generatedPassword
    case .idCard:
      self = .idCard
    case .identity:
      self = .identity
    case .passport:
      self = .passport
    case .phone:
      self = .phone
    case .secureFileInfo:
      self = .secureFileInfo
    case .secureNote:
      self = .secureNote
    case .secureNoteCategory:
      self = .secureNoteCategory
    case .securityBreach:
      self = .securityBreach
    case .settings:
      self = .settings
    case .socialSecurityInfo:
      self = .socialSecurityInfo
    case .taxNumber:
      self = .taxNumber
    case .website:
      self = .website
    case .passkey:
      self = .passkey
    case .secret:
      self = .secret
    case .dataChangeSets:
      return nil
    }
  }
}
