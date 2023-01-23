import Foundation
import SwiftUI
import CorePersonalData
import UIDelight
import DashlaneAppKit
import UIComponents

struct BankAccountDetailView: View {

    @ObservedObject
    var model: BankAccountDetailViewModel

    init(model: BankAccountDetailViewModel) {
        self.model = model
    }

    var body: some View {
        DetailContainerView(service: model.service) {
            Section {
                                if model.mode.isEditing {
                    TextDetailField(title: L10n.Localizable.KWBankStatementIOS.bankAccountName,
                                    text: $model.item.name,
                                    placeholder: L10n.Localizable.KWBankStatementIOS.BankAccountName.placeholder)
                    .textInputAutocapitalization(.words)
                }

                                PickerDetailField(title: L10n.Localizable.KWBankStatementIOS.localeFormat,
                                  selection: $model.selectedCountry,
                                  elements: CountryCodeNamePair.countries) { country in
                                    Text(country?.name ?? CountryCodeNamePair.defaultCountry.name)
                }

                                TextDetailField(title: L10n.Localizable.KWBankStatementIOS.bankAccountOwner, text: $model.item.owner)
                    .textInputAutocapitalization(.words)

                                SecureDetailField(title: L10n.Localizable.KWBankStatementIOS.bicFieldTitle(for: model.item.bicVariant),
                                  text: $model.item.bic,
                                  shouldReveal: $model.shouldReveal,
                                  formatter: .uppercase,
                                  obfuscatingFormatter: .obfuscatedCode,
                                  action: model.reveal,
                                  usagelogSubType: .bankAccountBIC)
                    .actions([.copy(model.copy), .largeDisplay],
                             accessHandler: model.requestAccess)
                    .textInputAutocapitalization(.characters)
                    .fiberFieldType(.bankAccountBIC)

                                SecureDetailField(title: L10n.Localizable.KWBankStatementIOS.ibanFieldTitle(for: model.item.ibanVariant),
                                  text: $model.item.iban,
                                  shouldReveal: $model.shouldReveal,
                                  formatter: .uppercase,
                                  obfuscatingFormatter: .obfuscatedCode,
                                  action: model.reveal,
                                  usagelogSubType: .bankAccountIBAN)
                    .actions([.copy(model.copy), .largeDisplay],
                             accessHandler: model.requestAccess)
                    .textInputAutocapitalization(.characters)
                    .fiberFieldType(.bankAccountIBAN)

                                if model.item.hasBankInformation {
                    PickerDetailField(title: L10n.Localizable.KWBankStatementIOS.bankAccountBank,
                                      selection: $model.selectedBank,
                                      elements: model.banks) { bank in
                                        Text(bank?.name ?? L10n.Localizable.kwLinkedDefaultOther)
                    }
                }
            }.makeShortcuts(model: model)
        }
    }
}

private extension View {

    func makeShortcuts(model: BankAccountDetailViewModel) -> some View {
        self
            .mainMenuShortcut(.copyPrimary(title: L10n.Localizable.copyIBAN),
                              enabled: !model.mode.isEditing && !model.item.iban.isEmpty,
                              action: { model.copy(model.item.iban, fieldType: .bankAccountIBAN) })
            .mainMenuShortcut(.copySecondary(title: L10n.Localizable.copyBic),
                              enabled: !model.mode.isEditing && !model.item.bic.isEmpty,
                              action: { model.copy(model.item.bic, fieldType: .bankAccountBIC) })
    }
}

struct BankAccountDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            BankAccountDetailView(model: MockVaultConnectedContainer().makeBankAccountDetailViewModel(item: PersonalDataMock.BankAccounts.personal, mode: .viewing))
            BankAccountDetailView(model: MockVaultConnectedContainer().makeBankAccountDetailViewModel(item: PersonalDataMock.BankAccounts.personal, mode: .updating))
        }
    }
}
