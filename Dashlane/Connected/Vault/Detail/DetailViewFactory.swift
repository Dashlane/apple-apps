import SwiftUI
import CorePersonalData
import Combine
import DashlaneAppKit
import VaultKit
import UIComponents
import DashTypes

enum ItemDetailViewType {
    case viewing(VaultItem, actionPublisher: PassthroughSubject<CredentialDetailViewModel.Action, Never>? = nil, origin: ItemDetailOrigin = .unknown)
    case editing(VaultItem)
    case adding(VaultItem.Type)
}

struct DetailViewFactory: SessionServicesInjecting {
    let credentialFactory: CredentialDetailViewModel.Factory
    let identityFactory: IdentityDetailViewModel.Factory
    let emailFactory: EmailDetailViewModel.Factory
    let companyFactory: CompanyDetailViewModel.Factory
    let personalWebsiteFactory: WebsiteDetailViewModel.Factory
    let phoneFactory: PhoneDetailViewModel.Factory
    let fiscalInfoFactory: FiscalInformationDetailViewModel.Factory
    let idCardFactory: IDCardDetailViewModel.Factory
    let passportFactory: PassportDetailViewModel.Factory
    let socialSecurityFactory: SocialSecurityDetailViewModel.Factory
    let drivingLicenseFactory: DrivingLicenseDetailViewModel.Factory
    let addressFactory: AddressDetailViewModel.Factory
    let creditCardFactory: CreditCardDetailViewModel.Factory
    let bankAccountFactory: BankAccountDetailViewModel.Factory
    let secureNoteFactory: SecureNotesDetailViewModel.Factory
    let passkeyFactory: PasskeyDetailViewModel.Factory

    init(credentialFactory: CredentialDetailViewModel.Factory,
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
         addressFactory: AddressDetailViewModel.Factory,
         creditCardFactory: CreditCardDetailViewModel.Factory,
         bankAccountFactory: BankAccountDetailViewModel.Factory,
         secureNoteFactory: SecureNotesDetailViewModel.Factory,
         passkeyFactory: PasskeyDetailViewModel.Factory
    ) {
        self.credentialFactory = credentialFactory
        self.identityFactory = identityFactory
        self.emailFactory = emailFactory
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
    }

    @ViewBuilder
    func view(for detailViewType: ItemDetailViewType) -> some View {
        switch detailViewType {
        case let .viewing(item, actionPublisher, origin):
            view(for: item, mode: .viewing, actionPublisher: actionPublisher, origin: origin)
        case let .editing(item):
            view(for: item, mode: .updating)
        case let .adding(itemType):
            view(for: itemType.init(), mode: .adding(prefilled: false))
        }
    }

    @ViewBuilder
    private func view(for item: VaultItem, mode: DetailMode, actionPublisher: PassthroughSubject<CredentialDetailViewModel.Action, Never>? = nil, origin: ItemDetailOrigin = .unknown) -> some View {
        switch item.enumerated {
        case let .credential(credential):
            let model = credentialFactory.make(item: credential, mode: mode, actionPublisher: actionPublisher, origin: origin)
            CredentialDetailView(model: model)
        case let .identity(identity):
            let model = identityFactory.make(item: identity, mode: mode)
            IdentityDetailView(model: model)
        case let .email(email):
            let model = emailFactory.make(item: email, mode: mode)
            EmailDetailView(model: model)
        case let .company(company):
            let model = companyFactory.make(item: company, mode: mode)
            CompanyDetailView(model: model)
        case let .personalWebsite(personalWebsite):
            let model = personalWebsiteFactory.make(item: personalWebsite, mode: mode)
            WebsiteDetailView(model: model)
        case let .phone(phone):
            let model = phoneFactory.make(item: phone, mode: mode)
            PhoneDetailView(model: model)
        case let .fiscalInformation(fiscalInfo):
            let model = fiscalInfoFactory.make(item: fiscalInfo, mode: mode)
            FiscalInformationDetailView(model: model)
        case let .idCard(idCard):
            let model = idCardFactory.make(item: idCard, mode: mode)
            IDCardDetailView(model: model)
        case let .passport(passport):
            let model = passportFactory.make(item: passport, mode: mode)
            PassportDetailView(model: model)
        case let .socialSecurityInformation(socialSecurity):
            let model = socialSecurityFactory.make(item: socialSecurity, mode: mode)
            SocialSecurityDetailView(model: model)
        case let .drivingLicence(drivingLicense):
            let model = drivingLicenseFactory.make(item: drivingLicense, mode: mode)
            DrivingLicenseDetailView(model: model)
        case let .address(address):
            let model = addressFactory.make(item: address, mode: mode)
            AddressDetailView(model: model)
        case let .creditCard(creditCard):
            let model = creditCardFactory.make(item: creditCard, mode: mode)
            CreditCardDetailView(model: model)
        case let .bankAccount(bankAccount):
            let model = bankAccountFactory.make(item: bankAccount, mode: mode)
            BankAccountDetailView(model: model)
        case let .secureNote(secureNote):
            let model = secureNoteFactory.make(item: secureNote, mode: mode)
            SecureNotesDetailView(model: model)
        case let .passkey(passkey):
            let model = passkeyFactory.make(item: passkey, mode: mode)
            PasskeyDetailView(model: model)
        }
    }
}

extension DetailViewFactory {
    static func mock() -> DetailViewFactory {
        let credentialViewModel = MockVaultConnectedContainer().makeCredentialDetailViewModel(service: .mock(item: Credential(), mode: .viewing))
        let identityViewModel = MockVaultConnectedContainer().makeIdentityDetailViewModel(service: .mock(item: Identity(), mode: .viewing))
        let emailViewModel = MockVaultConnectedContainer().makeEmailDetailViewModel(service: .mock(item: Email(), mode: .viewing))
        let companyViewModel = MockVaultConnectedContainer().makeCompanyDetailViewModel(service: .mock(item: Company(), mode: .viewing))
        let websiteViewModel = MockVaultConnectedContainer().makeWebsiteDetailViewModel(service: .mock(item: PersonalWebsite(), mode: .viewing))
        let phoneViewModel = MockVaultConnectedContainer().makePhoneDetailViewModel(service: .mock(item: Phone(), mode: .viewing))
        let fiscalInfoViewModel = MockVaultConnectedContainer().makeFiscalInformationDetailViewModel(service: .mock(item: FiscalInformation(), mode: .viewing))
        let idCardViewModel = MockVaultConnectedContainer().makeIDCardDetailViewModel(service: .mock(item: IDCard(), mode: .viewing))
        let passportViewModel = MockVaultConnectedContainer().makePassportDetailViewModel(service: .mock(item: Passport(), mode: .viewing))
        let socialViewModel = MockVaultConnectedContainer().makeSocialSecurityDetailViewModel(service: .mock(item: SocialSecurityInformation(), mode: .viewing))
        let drivingLicenseViewModel = MockVaultConnectedContainer().makeDrivingLicenseDetailViewModel(service: .mock(item: DrivingLicence(), mode: .viewing))
        let addressViewModel = MockVaultConnectedContainer().makeAddressDetailViewModel(service: .mock(item: Address(), mode: .viewing))
        let creditCardViewModel =  MockVaultConnectedContainer().makeCreditCardDetailViewModel(service: .mock(item: CreditCard(), mode: .viewing))
        let bankAccountViewModel =  MockVaultConnectedContainer().makeBankAccountDetailViewModel(service: .mock(item: BankAccount(), mode: .viewing))
        let secureNoteViewModel =  MockVaultConnectedContainer().makeSecureNotesDetailViewModel(service: .mock(item: SecureNote(), mode: .viewing))
        let passKeyViewModel =  MockVaultConnectedContainer().makePasskeyDetailViewModel(service: .mock(item: Passkey(), mode: .viewing))

        return .init(
            credentialFactory: .init { _, _, _, _, _, _ in credentialViewModel },
            identityFactory: .init { _, _ in identityViewModel },
            emailFactory: .init { _, _ in emailViewModel },
            companyFactory: .init { _, _  in companyViewModel },
            personalWebsiteFactory: .init { _, _ in websiteViewModel },
            phoneFactory: .init { _, _ in phoneViewModel },
            fiscalInfoFactory: .init { _, _ in fiscalInfoViewModel },
            idCardFactory: .init { _, _ in idCardViewModel },
            passportFactory: .init { _, _ in passportViewModel },
            socialSecurityFactory: .init { _, _ in socialViewModel },
            drivingLicenseFactory: .init { _, _ in drivingLicenseViewModel },
            addressFactory: .init { _, _, _ in addressViewModel },
            creditCardFactory: .init { _, _, _ in creditCardViewModel },
            bankAccountFactory: .init {_, _ in bankAccountViewModel },
            secureNoteFactory: .init { _, _ in secureNoteViewModel },
            passkeyFactory: .init {_, _, _  in passKeyViewModel })
    }
}
