import Combine
import CoreFeature
import CorePersonalData
import Foundation
import SwiftUI
import UIComponents
import VaultKit

struct VaultDetailView: View {

  private let itemDetailViewType: ItemDetailViewType
  private let viewModel: VaultDetailViewModel
  private let dismiss: DetailContainerViewSpecificAction?

  init(
    model: VaultDetailViewModel,
    itemDetailViewType: ItemDetailViewType,
    dismiss: DetailContainerViewSpecificAction? = nil
  ) {
    self.itemDetailViewType = itemDetailViewType
    self.dismiss = dismiss
    self.viewModel = model
  }

  var body: some View {
    view(for: itemDetailViewType)
      .detailContainerViewSpecificDismiss(dismiss)
  }

  @MainActor @ViewBuilder
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

  @MainActor @ViewBuilder
  private func view(
    for item: VaultItem,
    mode: DetailMode,
    actionPublisher: PassthroughSubject<CredentialDetailViewModel.Action, Never>? = nil,
    origin: ItemDetailOrigin = .unknown
  ) -> some View {
    switch item.enumerated {
    case let .credential(credential):
      CredentialDetailView(
        model: viewModel.makeCredentialDetailViewModel(
          credential: credential,
          mode: mode,
          actionPublisher: actionPublisher,
          origin: origin
        )
      )
    case let .identity(identity):
      IdentityDetailView(
        model: viewModel.makeIdentityDetailViewModel(identity: identity, mode: mode))
    case let .email(email):
      EmailDetailView(model: viewModel.makeEmailDetailViewModel(email: email, mode: mode))
    case let .company(company):
      CompanyDetailView(model: viewModel.makeCompanyDetailViewModel(company: company, mode: mode))
    case let .personalWebsite(personalWebsite):
      WebsiteDetailView(
        model: viewModel.makeWebsiteDetailViewModel(website: personalWebsite, mode: mode))
    case let .phone(phone):
      PhoneDetailView(model: viewModel.makePhoneDetailViewModel(phone: phone, mode: mode))
    case let .fiscalInformation(fiscalInfo):
      FiscalInformationDetailView(
        model: viewModel.makeFiscalInformationDetailViewModel(
          fiscalInformation: fiscalInfo, mode: mode)
      )
    case let .idCard(idCard):
      IDCardDetailView(model: viewModel.makeIDCardDetailViewModel(idCard: idCard, mode: mode))
    case let .passport(passport):
      PassportDetailView(
        model: viewModel.makePassportDetailViewModel(passport: passport, mode: mode))
    case let .socialSecurityInformation(socialSecurity):
      SocialSecurityDetailView(
        model: viewModel.makeSocialSecurityDetailViewModel(
          socialSecutity: socialSecurity, mode: mode)
      )
    case let .drivingLicence(drivingLicense):
      DrivingLicenseDetailView(
        model: viewModel.makeDrivingLicenseDetailViewModel(
          drivingLicense: drivingLicense, mode: mode)
      )
    case let .address(address):
      AddressDetailView(model: viewModel.makeAddressDetailViewModel(address: address, mode: mode))
    case let .creditCard(creditCard):
      CreditCardDetailView(
        model: viewModel.makeCreditCardDetailViewModel(creditCard: creditCard, mode: mode))
    case let .bankAccount(bankAccount):
      BankAccountDetailView(
        model: viewModel.makeBankAccountDetailViewModel(bankAccount: bankAccount, mode: mode))
    case let .secureNote(secureNote):
      SecureNotesDetailView(
        model: viewModel.makeSecureNotesDetailViewModel(secureNote: secureNote, mode: mode))
    case let .passkey(passkey):
      PasskeyDetailView(model: viewModel.makePasskeyDetailViewModel(passkey: passkey, mode: mode))
    case let .secret(secret):
      SecretDetailView(model: viewModel.makeSecretDetailViewModel(secret: secret, mode: mode))
    }
  }
}
