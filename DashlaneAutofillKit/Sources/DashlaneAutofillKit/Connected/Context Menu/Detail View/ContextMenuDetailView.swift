import CoreLocalization
import CorePersonalData
import Foundation
import SwiftTreats
import SwiftUI
import UIComponents
import VaultKit

struct ContextMenuDetailView: View {

  private let vaultItem: VaultItem
  private let viewModel: ContextMenuDetailViewModel

  init(
    model: ContextMenuDetailViewModel,
    vaultItem: VaultItem
  ) {
    self.viewModel = model
    self.vaultItem = vaultItem
  }

  var body: some View {
    view(for: vaultItem)
  }

  @MainActor @ViewBuilder
  private func view(for item: VaultItem) -> some View {
    switch item.enumerated {
    case let .credential(credential):
      ContextMenuCredentialDetailView(
        model: viewModel.makeCredentialDetailViewModel(credential: credential))
    case let .creditCard(creditCard):
      ContextMenuCreditCardDetailView(
        model: viewModel.makeCreditCardDetailViewModel(creditCard: creditCard)
      )
      .toasterOn()
    case let .bankAccount(bankAccount):
      ContextMenuBankAccountDetailView(
        model: viewModel.makeBankAccountDetailViewModel(bankAccount: bankAccount))
    case let .identity(identity):
      ContextMenuNameDetailView(model: viewModel.makeIdentityDetailViewModel(identity: identity))
        .toasterOn()
    case let .email(email):
      ContextMenuEmailDetailView(model: viewModel.makeEmailDetailViewModel(email: email))
    case let .phone(phone):
      ContextMenuPhoneDetailView(model: viewModel.makePhoneDetailViewModel(phone: phone))
    case let .address(address):
      ContextMenuAddressDetailView(model: viewModel.makeAddressDetailViewModel(address: address))
    case let .company(company):
      ContextMenuCompanyDetailView(model: viewModel.makeCompanyDetailViewModel(company: company))
    case let .personalWebsite(website):
      ContextMenuWebsiteDetailView(model: viewModel.makeWebsiteDetailViewModel(website: website))
    case let .idCard(idCard):
      ContextMenuIDCardDetailView(model: viewModel.makeIDCardDetailViewModel(idCard: idCard))
        .toasterOn()
    case let .socialSecurityInformation(socialSecurity):
      ContextMenuSocialSecurityDetailView(
        model: viewModel.makeSocialSecurityDetailViewModel(socialSecurity: socialSecurity)
      )
      .toasterOn()
    case let .drivingLicence(drivingLicense):
      ContextMenuDrivingLicenseDetailView(
        model: viewModel.makeDrivingLicenseDetailViewModel(drivingLicense: drivingLicense)
      )
      .toasterOn()
    case let .passport(passport):
      ContextMenuPassportDetailView(
        model: viewModel.makePassportDetailViewModel(passport: passport)
      )
      .toasterOn()
    case let .fiscalInformation(fiscalInformation):
      ContextMenuFiscalInformationDetailView(
        model: viewModel.makeFiscalInformationDetailViewModel(fiscalInformation: fiscalInformation))
    case let .secret(secret):
      ContextMenuSecretDetailView(model: viewModel.makeSecretDetailViewModel(secret: secret))
    case .secureNote, .passkey, .wifi:
      Text("Item is not supported for autofill")
    }
  }
}
