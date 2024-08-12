import DashTypes
import Foundation

extension PersonalDataContentType {
  var personalDataType: any PersonalDataCodable.Type {
    switch self {
    case .address:
      return Address.self
    case .bankAccount:
      return BankAccount.self
    case .company:
      return Company.self
    case .collection:
      return PrivateCollection.self
    case .credential:
      return Credential.self
    case .credentialCategory:
      return CredentialCategory.self
    case .creditCard:
      return CreditCard.self
    case .dataChangeHistory:
      return DataChangeHistory.self
    case .driverLicence:
      return DrivingLicence.self
    case .email:
      return Email.self
    case .generatedPassword:
      return GeneratedPassword.self
    case .idCard:
      return IDCard.self
    case .identity:
      return Identity.self
    case .passport:
      return Passport.self
    case .phone:
      return Phone.self
    case .secureFileInfo:
      return SecureFileInformation.self
    case .secureNote:
      return SecureNote.self
    case .secureNoteCategory:
      return SecureNoteCategory.self
    case .securityBreach:
      return SecurityBreach.self
    case .settings:
      return Settings.self
    case .socialSecurityInfo:
      return SocialSecurityInformation.self
    case .taxNumber:
      return FiscalInformation.self
    case .website:
      return PersonalWebsite.self
    case .passkey:
      return Passkey.self
    case .secret:
      return Secret.self
    }
  }
}
