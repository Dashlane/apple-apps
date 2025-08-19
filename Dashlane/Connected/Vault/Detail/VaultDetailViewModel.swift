import Combine
import CorePersonalData
import CoreTypes
import SwiftUI
import UIComponents
import VaultKit

enum ItemDetailViewType {
  case viewing(
    VaultItem, actionPublisher: PassthroughSubject<CredentialDetailViewModel.Action, Never>? = nil,
    origin: ItemDetailOrigin = .unknown)
  case editing(VaultItem)
  case adding(VaultItem.Type)
}

struct VaultDetailViewModel: SessionServicesInjecting {
  private let credentialFactory: CredentialDetailViewModel.Factory
  private let identityFactory: IdentityDetailViewModel.Factory
  private let emailFactory: EmailDetailViewModel.Factory
  private let companyFactory: CompanyDetailViewModel.Factory
  private let personalWebsiteFactory: WebsiteDetailViewModel.Factory
  private let phoneFactory: PhoneDetailViewModel.Factory
  private let fiscalInfoFactory: FiscalInformationDetailViewModel.Factory
  private let idCardFactory: IDCardDetailViewModel.Factory
  let secretFactory: SecretDetailViewModel.Factory
  private let passportFactory: PassportDetailViewModel.Factory
  private let socialSecurityFactory: SocialSecurityDetailViewModel.Factory
  private let drivingLicenseFactory: DrivingLicenseDetailViewModel.Factory
  private let addressFactory: AddressDetailViewModel.Factory
  private let creditCardFactory: CreditCardDetailViewModel.Factory
  private let bankAccountFactory: BankAccountDetailViewModel.Factory
  private let secureNoteFactory: SecureNotesDetailViewModel.Factory
  private let passkeyFactory: PasskeyDetailViewModel.Factory
  private let wifiFactory: WifiDetailViewModel.Factory

  public init(
    credentialFactory: CredentialDetailViewModel.Factory,
    identityFactory: IdentityDetailViewModel.Factory,
    emailFactory: EmailDetailViewModel.Factory,
    companyFactory: CompanyDetailViewModel.Factory,
    personalWebsiteFactory: WebsiteDetailViewModel.Factory,
    phoneFactory: PhoneDetailViewModel.Factory,
    fiscalInfoFactory: FiscalInformationDetailViewModel.Factory,
    idCardFactory: IDCardDetailViewModel.Factory,
    passportFactory: PassportDetailViewModel.Factory,
    socialSecurityFactory: SocialSecurityDetailViewModel.Factory,
    drivingLicenseFactory: DrivingLicenseDetailViewModel.Factory,
    secretFactory: SecretDetailViewModel.Factory,
    addressFactory: AddressDetailViewModel.Factory,
    creditCardFactory: CreditCardDetailViewModel.Factory,
    bankAccountFactory: BankAccountDetailViewModel.Factory,
    secureNoteFactory: SecureNotesDetailViewModel.Factory,
    passkeyFactory: PasskeyDetailViewModel.Factory,
    wifiFactory: WifiDetailViewModel.Factory
  ) {
    self.credentialFactory = credentialFactory
    self.identityFactory = identityFactory
    self.emailFactory = emailFactory
    self.secretFactory = secretFactory
    self.companyFactory = companyFactory
    self.personalWebsiteFactory = personalWebsiteFactory
    self.phoneFactory = phoneFactory
    self.fiscalInfoFactory = fiscalInfoFactory
    self.idCardFactory = idCardFactory
    self.passportFactory = passportFactory
    self.socialSecurityFactory = socialSecurityFactory
    self.drivingLicenseFactory = drivingLicenseFactory
    self.addressFactory = addressFactory
    self.creditCardFactory = creditCardFactory
    self.bankAccountFactory = bankAccountFactory
    self.secureNoteFactory = secureNoteFactory
    self.passkeyFactory = passkeyFactory
    self.wifiFactory = wifiFactory
  }

  @MainActor
  func makeCredentialDetailViewModel(
    credential: Credential,
    mode: DetailMode,
    actionPublisher: PassthroughSubject<CredentialDetailViewModel.Action, Never>? = nil,
    origin: ItemDetailOrigin = .unknown
  ) -> CredentialDetailViewModel {
    credentialFactory.make(
      item: credential, mode: mode, actionPublisher: actionPublisher, origin: origin)
  }

  @MainActor
  func makeIdentityDetailViewModel(identity: Identity, mode: DetailMode) -> IdentityDetailViewModel
  {
    identityFactory.make(item: identity, mode: mode)
  }

  @MainActor
  func makeEmailDetailViewModel(email: CorePersonalData.Email, mode: DetailMode)
    -> EmailDetailViewModel
  {
    emailFactory.make(item: email, mode: mode)
  }

  @MainActor
  func makeCompanyDetailViewModel(company: Company, mode: DetailMode) -> CompanyDetailViewModel {
    companyFactory.make(item: company, mode: mode)
  }

  @MainActor
  func makeWebsiteDetailViewModel(website: PersonalWebsite, mode: DetailMode)
    -> WebsiteDetailViewModel
  {
    personalWebsiteFactory.make(item: website, mode: mode)
  }

  @MainActor
  func makePhoneDetailViewModel(phone: Phone, mode: DetailMode) -> PhoneDetailViewModel {
    phoneFactory.make(item: phone, mode: mode)
  }

  @MainActor
  func makeFiscalInformationDetailViewModel(fiscalInformation: FiscalInformation, mode: DetailMode)
    -> FiscalInformationDetailViewModel
  {
    fiscalInfoFactory.make(item: fiscalInformation, mode: mode)
  }

  @MainActor
  func makeIDCardDetailViewModel(idCard: IDCard, mode: DetailMode) -> IDCardDetailViewModel {
    idCardFactory.make(item: idCard, mode: mode)
  }

  @MainActor
  func makePassportDetailViewModel(passport: Passport, mode: DetailMode) -> PassportDetailViewModel
  {
    passportFactory.make(item: passport, mode: mode)
  }

  @MainActor
  func makeSocialSecurityDetailViewModel(
    socialSecutity: SocialSecurityInformation, mode: DetailMode
  ) -> SocialSecurityDetailViewModel {
    socialSecurityFactory.make(item: socialSecutity, mode: mode)
  }

  @MainActor
  func makeDrivingLicenseDetailViewModel(drivingLicense: DrivingLicence, mode: DetailMode)
    -> DrivingLicenseDetailViewModel
  {
    drivingLicenseFactory.make(item: drivingLicense, mode: mode)
  }

  @MainActor
  func makeAddressDetailViewModel(address: Address, mode: DetailMode) -> AddressDetailViewModel {
    addressFactory.make(item: address, mode: mode)
  }

  @MainActor
  func makeCreditCardDetailViewModel(creditCard: CreditCard, mode: DetailMode)
    -> CreditCardDetailViewModel
  {
    creditCardFactory.make(item: creditCard, mode: mode)
  }

  @MainActor
  func makeBankAccountDetailViewModel(bankAccount: BankAccount, mode: DetailMode)
    -> BankAccountDetailViewModel
  {
    bankAccountFactory.make(item: bankAccount, mode: mode)
  }

  @MainActor
  func makeSecureNotesDetailViewModel(secureNote: SecureNote, mode: DetailMode)
    -> SecureNotesDetailViewModel
  {
    secureNoteFactory.make(item: secureNote, mode: mode)
  }

  @MainActor
  func makePasskeyDetailViewModel(passkey: Passkey, mode: DetailMode) -> PasskeyDetailViewModel {
    passkeyFactory.make(item: passkey, mode: mode)
  }

  @MainActor
  func makeSecretDetailViewModel(secret: Secret, mode: DetailMode) -> SecretDetailViewModel {
    secretFactory.make(item: secret, mode: mode)
  }

  @MainActor
  func makeWifiDetailViewModel(wifi: WiFi, mode: DetailMode) -> WifiDetailViewModel {
    wifiFactory.make(item: wifi, mode: mode)
  }
}

@MainActor
extension VaultDetailViewModel {

  static func mock() -> VaultDetailViewModel {
    let credentialViewModel = MockVaultConnectedContainer().makeCredentialDetailViewModel(
      service: .mock(item: Credential(), mode: .viewing))
    let identityViewModel = MockVaultConnectedContainer().makeIdentityDetailViewModel(
      service: .mock(item: Identity(), mode: .viewing))
    let emailViewModel = MockVaultConnectedContainer().makeEmailDetailViewModel(
      service: .mock(item: Email(), mode: .viewing))
    let companyViewModel = MockVaultConnectedContainer().makeCompanyDetailViewModel(
      service: .mock(item: Company(), mode: .viewing))
    let websiteViewModel = MockVaultConnectedContainer().makeWebsiteDetailViewModel(
      service: .mock(item: PersonalWebsite(), mode: .viewing))
    let phoneViewModel = MockVaultConnectedContainer().makePhoneDetailViewModel(
      service: .mock(item: Phone(), mode: .viewing))
    let fiscalInfoViewModel = MockVaultConnectedContainer().makeFiscalInformationDetailViewModel(
      service: .mock(item: FiscalInformation(), mode: .viewing))
    let idCardViewModel = MockVaultConnectedContainer().makeIDCardDetailViewModel(
      service: .mock(item: IDCard(), mode: .viewing))
    let passportViewModel = MockVaultConnectedContainer().makePassportDetailViewModel(
      service: .mock(item: Passport(), mode: .viewing))
    let socialViewModel = MockVaultConnectedContainer().makeSocialSecurityDetailViewModel(
      service: .mock(item: SocialSecurityInformation(), mode: .viewing))
    let drivingLicenseViewModel = MockVaultConnectedContainer().makeDrivingLicenseDetailViewModel(
      service: .mock(item: DrivingLicence(), mode: .viewing))
    let addressViewModel = MockVaultConnectedContainer().makeAddressDetailViewModel(
      service: .mock(item: Address(), mode: .viewing))
    let creditCardViewModel = MockVaultConnectedContainer().makeCreditCardDetailViewModel(
      service: .mock(item: CreditCard(), mode: .viewing))
    let bankAccountViewModel = MockVaultConnectedContainer().makeBankAccountDetailViewModel(
      service: .mock(item: BankAccount(), mode: .viewing))
    let secureNoteViewModel = MockVaultConnectedContainer().makeSecureNotesDetailViewModel(
      service: .mock(item: SecureNote(), mode: .viewing))
    let passKeyViewModel = MockVaultConnectedContainer().makePasskeyDetailViewModel(
      service: .mock(item: Passkey(), mode: .viewing))
    let secretsViewModel = MockVaultConnectedContainer().makeSecretDetailViewModel(
      service: .mock(item: Secret(), mode: .viewing))
    let wifiViewModel = MockVaultConnectedContainer().makeWifiDetailViewModel(
      service: .mock(item: WiFi(), mode: .viewing))

    return .init(
      credentialFactory: .init { _, _, _, _, _, _ in credentialViewModel },
      identityFactory: .init { _, _ in identityViewModel },
      emailFactory: .init { _, _ in emailViewModel },
      companyFactory: .init { _, _ in companyViewModel },
      personalWebsiteFactory: .init { _, _ in websiteViewModel },
      phoneFactory: .init { _, _ in phoneViewModel },
      fiscalInfoFactory: .init { _, _ in fiscalInfoViewModel },
      idCardFactory: .init { _, _ in idCardViewModel },
      passportFactory: .init { _, _ in passportViewModel },
      socialSecurityFactory: .init { _, _ in socialViewModel },
      drivingLicenseFactory: .init { _, _ in drivingLicenseViewModel },
      secretFactory: .init { _, _ in secretsViewModel },
      addressFactory: .init { _, _, _ in addressViewModel },
      creditCardFactory: .init { _, _, _ in creditCardViewModel },
      bankAccountFactory: .init { _, _ in bankAccountViewModel },
      secureNoteFactory: .init { _, _ in secureNoteViewModel },
      passkeyFactory: .init { _, _, _ in passKeyViewModel },
      wifiFactory: .init { _, _ in wifiViewModel })
  }
}
