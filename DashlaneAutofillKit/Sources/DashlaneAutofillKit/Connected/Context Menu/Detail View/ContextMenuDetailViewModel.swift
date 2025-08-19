import Combine
import CorePersonalData
import CoreSettings
import CoreTypes
import Foundation
import UIComponents
import VaultKit

struct ContextMenuDetailViewModel: SessionServicesInjecting {

  let vaultItemDatabase: VaultItemDatabaseProtocol
  let completion: (VaultItem, String) -> Void

  private let credentialFactory: ContextMenuCredentialDetailViewModel.Factory
  private let creditCardFactory: ContextMenuCreditCardDetailViewModel.Factory
  private let bankAccountFactory: ContextMenuBankAccountDetailViewModel.Factory
  private let identityFactory: ContextMenuNameDetailViewModel.Factory
  private let emailFactory: ContextMenuEmailDetailViewModel.Factory
  private let phoneFactory: ContextMenuPhoneDetailViewModel.Factory
  private let addressFactory: ContextMenuAddressDetailViewModel.Factory
  private let companyFactory: ContextMenuCompanyDetailViewModel.Factory
  private let websiteFactory: ContextMenuWebsiteDetailViewModel.Factory
  private let idCardFactory: ContextMenuIDCardDetailViewModel.Factory
  private let socialSecurityFactory: ContextMenuSocialSecurityDetailViewModel.Factory
  private let drivingLicenseFactory: ContextMenuDrivingLicenseDetailViewModel.Factory
  private let passportFactory: ContextMenuPassportDetailViewModel.Factory
  private let fiscalInformationFactory: ContextMenuFiscalInformationDetailViewModel.Factory
  private let secretFactory: ContextMenuSecretDetailViewModel.Factory

  public init(
    vaultItemDatabase: VaultItemDatabaseProtocol,
    completion: @escaping (VaultItem, String) -> Void,
    credentialFactory: ContextMenuCredentialDetailViewModel.Factory,
    creditCardFactory: ContextMenuCreditCardDetailViewModel.Factory,
    bankAccountFactory: ContextMenuBankAccountDetailViewModel.Factory,
    identityFactory: ContextMenuNameDetailViewModel.Factory,
    emailFactory: ContextMenuEmailDetailViewModel.Factory,
    phoneFactory: ContextMenuPhoneDetailViewModel.Factory,
    addressFactory: ContextMenuAddressDetailViewModel.Factory,
    companyFactory: ContextMenuCompanyDetailViewModel.Factory,
    websiteFactory: ContextMenuWebsiteDetailViewModel.Factory,
    idCardFactory: ContextMenuIDCardDetailViewModel.Factory,
    socialSecurityFactory: ContextMenuSocialSecurityDetailViewModel.Factory,
    drivingLicenseFactory: ContextMenuDrivingLicenseDetailViewModel.Factory,
    passportFactory: ContextMenuPassportDetailViewModel.Factory,
    fiscalInformationFactory: ContextMenuFiscalInformationDetailViewModel.Factory,
    secretFactory: ContextMenuSecretDetailViewModel.Factory
  ) {
    self.vaultItemDatabase = vaultItemDatabase
    self.completion = completion
    self.credentialFactory = credentialFactory
    self.creditCardFactory = creditCardFactory
    self.bankAccountFactory = bankAccountFactory
    self.identityFactory = identityFactory
    self.emailFactory = emailFactory
    self.phoneFactory = phoneFactory
    self.addressFactory = addressFactory
    self.companyFactory = companyFactory
    self.websiteFactory = websiteFactory
    self.idCardFactory = idCardFactory
    self.socialSecurityFactory = socialSecurityFactory
    self.drivingLicenseFactory = drivingLicenseFactory
    self.passportFactory = passportFactory
    self.fiscalInformationFactory = fiscalInformationFactory
    self.secretFactory = secretFactory
  }

  @MainActor
  func makeCredentialDetailViewModel(credential: Credential) -> ContextMenuCredentialDetailViewModel
  {
    credentialFactory.make(
      vaultItemDatabase: vaultItemDatabase, item: credential, completion: completion)
  }

  @MainActor
  func makeCreditCardDetailViewModel(creditCard: CreditCard) -> ContextMenuCreditCardDetailViewModel
  {
    creditCardFactory.make(
      vaultItemDatabase: vaultItemDatabase, item: creditCard, completion: completion)
  }

  @MainActor
  func makeBankAccountDetailViewModel(bankAccount: BankAccount)
    -> ContextMenuBankAccountDetailViewModel
  {
    bankAccountFactory.make(
      vaultItemDatabase: vaultItemDatabase, item: bankAccount, completion: completion)
  }

  @MainActor
  func makeIdentityDetailViewModel(identity: Identity) -> ContextMenuNameDetailViewModel {
    identityFactory.make(
      vaultItemDatabase: vaultItemDatabase, item: identity, completion: completion)
  }

  @MainActor
  func makeEmailDetailViewModel(email: CorePersonalData.Email) -> ContextMenuEmailDetailViewModel {
    emailFactory.make(vaultItemDatabase: vaultItemDatabase, item: email, completion: completion)
  }

  @MainActor
  func makePhoneDetailViewModel(phone: Phone) -> ContextMenuPhoneDetailViewModel {
    phoneFactory.make(vaultItemDatabase: vaultItemDatabase, item: phone, completion: completion)
  }

  @MainActor
  func makeAddressDetailViewModel(address: Address) -> ContextMenuAddressDetailViewModel {
    addressFactory.make(vaultItemDatabase: vaultItemDatabase, item: address, completion: completion)
  }

  @MainActor
  func makeCompanyDetailViewModel(company: Company) -> ContextMenuCompanyDetailViewModel {
    companyFactory.make(vaultItemDatabase: vaultItemDatabase, item: company, completion: completion)
  }

  @MainActor
  func makeWebsiteDetailViewModel(website: PersonalWebsite) -> ContextMenuWebsiteDetailViewModel {
    websiteFactory.make(vaultItemDatabase: vaultItemDatabase, item: website, completion: completion)
  }

  @MainActor
  func makeIDCardDetailViewModel(idCard: IDCard) -> ContextMenuIDCardDetailViewModel {
    idCardFactory.make(vaultItemDatabase: vaultItemDatabase, item: idCard, completion: completion)
  }

  @MainActor
  func makeSocialSecurityDetailViewModel(socialSecurity: SocialSecurityInformation)
    -> ContextMenuSocialSecurityDetailViewModel
  {
    socialSecurityFactory.make(
      vaultItemDatabase: vaultItemDatabase, item: socialSecurity, completion: completion)
  }

  @MainActor
  func makeDrivingLicenseDetailViewModel(drivingLicense: DrivingLicence)
    -> ContextMenuDrivingLicenseDetailViewModel
  {
    drivingLicenseFactory.make(
      vaultItemDatabase: vaultItemDatabase, item: drivingLicense, completion: completion)
  }

  @MainActor
  func makePassportDetailViewModel(passport: Passport) -> ContextMenuPassportDetailViewModel {
    passportFactory.make(
      vaultItemDatabase: vaultItemDatabase, item: passport, completion: completion)
  }

  @MainActor
  func makeFiscalInformationDetailViewModel(fiscalInformation: FiscalInformation)
    -> ContextMenuFiscalInformationDetailViewModel
  {
    fiscalInformationFactory.make(
      vaultItemDatabase: vaultItemDatabase, item: fiscalInformation, completion: completion)
  }

  @MainActor
  func makeSecretDetailViewModel(secret: Secret) -> ContextMenuSecretDetailViewModel {
    secretFactory.make(vaultItemDatabase: vaultItemDatabase, item: secret, completion: completion)
  }
}
