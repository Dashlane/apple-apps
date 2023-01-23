import SwiftUI
import CorePersonalData
import Combine
import DashlaneAppKit
import VaultKit

enum ItemDetailViewType {
    case viewing(VaultItem, actionPublisher: PassthroughSubject<CredentialDetailViewModel.Action, Never>? = nil, origin: ItemDetailOrigin = .unknown)
    case editing(VaultItem)
    case adding(VaultItem.Type)
}

struct DetailViewFactory {
    let sessionServices: SessionServicesContainer

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
            let model = sessionServices
                .viewModelFactory
                .makeCredentialDetailViewModel(item: credential, mode: mode, actionPublisher: actionPublisher, origin: origin)
            CredentialDetailView(model: model)
        case let .identity(identity):
            let model = sessionServices
                .viewModelFactory
                .makeIdentityDetailViewModel(item: identity, mode: mode)
            IdentityDetailView(model: model)
        case let .email(email):
            let model = sessionServices
                .viewModelFactory
                .makeEmailDetailViewModel(item: email, mode: mode)
            EmailDetailView(model: model)
        case let .company(company):
            let model = sessionServices
                .viewModelFactory
                .makeCompanyDetailViewModel(item: company, mode: mode)
            CompanyDetailView(model: model)
        case let .personalWebsite(personalWebsite):
            let model = sessionServices
                .viewModelFactory
                .makeWebsiteDetailViewModel(item: personalWebsite, mode: mode)
            WebsiteDetailView(model: model)
        case let .phone(phone):
            let model = sessionServices
                .viewModelFactory
                .makePhoneDetailViewModel(item: phone, mode: mode)
            PhoneDetailView(model: model)
        case let .fiscalInformation(fiscalInfo):
            let model = sessionServices
                .viewModelFactory
                .makeFiscalInformationDetailViewModel(item: fiscalInfo, mode: mode)
            FiscalInformationDetailView(model: model)
        case let .idCard(idCard):
            let model = sessionServices
                .viewModelFactory
                .makeIDCardDetailViewModel(item: idCard, mode: mode)
            IDCardDetailView(model: model)
        case let .passport(passport):
            let model = sessionServices
                .viewModelFactory
                .makePassportDetailViewModel(item: passport, mode: mode)
            PassportDetailView(model: model)
        case let .socialSecurityInformation(socialSecurity):
            let model = sessionServices
                .viewModelFactory
                .makeSocialSecurityDetailViewModel(item: socialSecurity, mode: mode)
            SocialSecurityDetailView(model: model)
        case let .drivingLicence(drivingLicense):
            let model = sessionServices
                .viewModelFactory
                .makeDrivingLicenseDetailViewModel(item: drivingLicense, mode: mode)
            DrivingLicenseDetailView(model: model)
        case let .address(address):
            let model = sessionServices
                .viewModelFactory
                .makeAddressDetailViewModel(item: address, mode: mode)
            AddressDetailView(model: model)
        case let .creditCard(creditCard):
            let model = sessionServices
                .viewModelFactory
                .makeCreditCardDetailViewModel(item: creditCard, mode: mode)
            CreditCardDetailView(model: model)
        case let .bankAccount(bankAccount):
            let model = sessionServices
                .viewModelFactory
                .makeBankAccountDetailViewModel(item: bankAccount, mode: mode)
            BankAccountDetailView(model: model)
        case let .secureNote(secureNote):
            let model = sessionServices
                .viewModelFactory
                .makeSecureNotesDetailViewModel(item: secureNote, mode: mode)
            SecureNotesDetailView(model: model)
        }
    }
}
