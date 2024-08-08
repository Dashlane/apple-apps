import CorePersonalData
import CoreUserTracking
import SwiftUI
import UIDelight
import VaultKit

struct VaultItemMenuContent: View {
  let item: VaultItem
  let copy: (Definition.Field, String) -> Void

  var body: some View {
    switch item.enumerated {
    case let .credential(credential):
      CredentialMenu(credential: credential, copyAction: copy)
    case let .secureNote(secureNote):
      SecureNoteMenu(secureNote: secureNote)
    case let .email(email):
      EmailMenu(email: email, copyAction: copy)
    case let .company(company):
      CompanyMenu(company: company, copyAction: copy)
    case let .personalWebsite(website):
      WebsiteMenu(website: website, copyAction: copy)
    case let .phone(phone):
      PhoneMenu(phone: phone, copyAction: copy)
    case let .fiscalInformation(fiscalInfo):
      FiscalInformationMenu(fiscalInformation: fiscalInfo, copyAction: copy)
    case let .idCard(idCard):
      IDCardMenu(idCard: idCard, copyAction: copy)
    case let .passport(passport):
      PassportMenu(passport: passport, copyAction: copy)
    case let .socialSecurityInformation(socialSecurity):
      SocialSecurityMenu(socialSecurity: socialSecurity, copyAction: copy)
    case let .drivingLicence(drivingLicense):
      DrivingLicenseMenu(drivingLicense: drivingLicense, copyAction: copy)
    case let .address(address):
      AddressMenu(address: address, copyAction: copy)
    case let .creditCard(creditCard):
      CreditCardMenu(creditCard: creditCard, copyAction: copy)
    case let .bankAccount(bankAccount):
      BankAccountMenu(bankAccount: bankAccount, copyAction: copy)
    case let .identity(identity):
      IdentityMenu(identity: identity, copyAction: copy)
    case let .passkey(passkey):
      PasskeyMenu(passkey: passkey, copyAction: copy)
    case let .secret(secret):
      SecretMenu(secret: secret, copyAction: copy)
    }
  }
}
