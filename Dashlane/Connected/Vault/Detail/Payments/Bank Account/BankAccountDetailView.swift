import Foundation
import SwiftUI
import CoreLocalization
import CorePersonalData
import UIDelight
import DashlaneAppKit
import UIComponents
import VaultKit

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
                    TextDetailField(title: CoreLocalization.L10n.Core.KWBankStatementIOS.bankAccountName,
                                    text: $model.item.name,
                                    placeholder: CoreLocalization.L10n.Core.KWBankStatementIOS.BankAccountName.placeholder)
                    .textInputAutocapitalization(.words)
                }

                                PickerDetailField(title: CoreLocalization.L10n.Core.KWBankStatementIOS.localeFormat,
                                  selection: $model.selectedCountry,
                                  elements: CountryCodeNamePair.countries) { country in
                                    Text(country?.name ?? CountryCodeNamePair.defaultCountry.name)
                }

                                TextDetailField(title: CoreLocalization.L10n.Core.KWBankStatementIOS.bankAccountOwner, text: $model.item.owner)
                    .textInputAutocapitalization(.words)

                                SecureDetailField(
                    title: CoreLocalization.L10n.Core.KWBankStatementIOS.bicFieldTitle(for: model.item.bicVariant),
                    text: $model.item.bic,
                    shouldReveal: $model.shouldReveal,
                    onRevealAction: model.reveal,
                    formatter: .uppercase,
                    obfuscatingFormatter: .obfuscatedCode,
                    actions: [.copy(model.copy)]
                )
                .actions([.copy(model.copy), .largeDisplay], accessHandler: model.requestAccess)
                .textInputAutocapitalization(.characters)
                .fiberFieldType(.bankAccountBIC)

                                SecureDetailField(
                    title: CoreLocalization.L10n.Core.KWBankStatementIOS.ibanFieldTitle(for: model.item.ibanVariant),
                    text: $model.item.iban,
                    shouldReveal: $model.shouldReveal,
                    onRevealAction: model.reveal,
                    formatter: .uppercase,
                    obfuscatingFormatter: .obfuscatedCode,
                    actions: [.copy(model.copy)]
                )
                .actions([.copy(model.copy), .largeDisplay], accessHandler: model.requestAccess)
                .textInputAutocapitalization(.characters)
                .fiberFieldType(.bankAccountIBAN)

                                if model.item.hasBankInformation {
                    PickerDetailField(title: CoreLocalization.L10n.Core.KWBankStatementIOS.bankAccountBank,
                                      selection: $model.selectedBank,
                                      elements: model.banks) { bank in
                        Text(bank?.name ?? CoreLocalization.L10n.Core.kwLinkedDefaultOther)
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
