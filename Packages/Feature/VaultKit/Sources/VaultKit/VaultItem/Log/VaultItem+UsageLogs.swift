import CorePersonalData
import Foundation
import UserTrackingFoundation

extension VaultItem {
  public var vaultItemType: Definition.ItemType {
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
      return .driverLicense
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
    case .passkey:
      return .passkey
    case .secret:
      return .secret
    case .wifi:
      return .wifi
    }
  }
}
