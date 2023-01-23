import Foundation
import SwiftUI
import CorePersonalData
import UIDelight

struct CreditCardDetailView: View {

    @ObservedObject
    var model: CreditCardDetailViewModel

    init(model: CreditCardDetailViewModel) {
        self.model = model
    }

    var body: some View {
        DetailContainerView(service: model.service) {
            Section {
                                if model.mode.isEditing {
                    TextDetailField(title: L10n.Localizable.KWPaymentMeanCreditCardIOS.name, text: $model.item.name)
                        .textInputAutocapitalization(.words)
                }

                                PickerDetailField(title: L10n.Localizable.KWPaymentMeanCreditCardIOS.localeFormat,
                                  selection: $model.selectedCountry,
                                  elements: CountryCodeNamePair.countries) { country in
                                    Text(country?.name ?? CountryCodeNamePair.defaultCountry.name)
                }

                                TextDetailField(title: L10n.Localizable.KWPaymentMeanCreditCardIOS.ownerName, text: $model.item.ownerName)
                    .textInputAutocapitalization(.words)

                                SecureDetailField(title: L10n.Localizable.KWPaymentMeanCreditCardIOS.cardNumber,
                                  text: $model.item.cardNumber,
                                  shouldReveal: $model.shouldReveal,
                                  formatter: CreditCardNumberFormatter(),
                                  obfuscatingFormatter: CreditCardNumberFormatter(obfuscate: true),
                                  action: model.reveal,
                                  usagelogSubType: .cardNumber)
                    .actions([.copy(model.copy), .largeDisplay], accessHandler: model.requestAccess)
                    .keyboardType(.numberPad)
                    .fiberFieldType(.cardNumber)

                                if model.mode.isEditing || !model.item.securityCode.isEmpty {
                    SecureDetailField(title: L10n.Localizable.KWPaymentMeanCreditCardIOS.securityCode,
                                      text: $model.item.securityCode,
                                      shouldReveal: $model.shouldReveal,
                                      hasDisplayEmptyIndicator: false,
                                      formatter: .uppercase,
                                      obfuscatingFormatter: .obfuscatedCode,
                                      action: model.reveal,
                                      usagelogSubType: .securityCode)
                        .actions([.copy(model.copy), .largeDisplay], accessHandler: model.requestAccess)
                        .keyboardType(.numberPad)
                        .fiberFieldType(.securityCode)
                }

                                if model.mode.isEditing || !model.item.note.isEmpty {
                    SecureDetailField(title: L10n.Localizable.KWPaymentMeanCreditCardIOS.ccNote,
                                      text: $model.item.note,
                                      shouldReveal: $model.shouldReveal,
                                      hasDisplayEmptyIndicator: false,
                                      obfuscatingFormatter: .obfuscatedCode(max: 4),
                                      action: model.reveal,
                                      usagelogSubType: .note)
                        .actions([.copy(model.copy), .largeDisplay], accessHandler: model.requestAccess)
                        .fiberFieldType(.cCNote)
                }

                                DateDetailField(title: L10n.Localizable.KWPaymentMeanCreditCardIOS.expiryDateForUi,
                                date: $model.item.editableExpireDate,
                                formatter: CreditCard.expireDateFormatter,
                                range: DateRange.future,
                                mode: .monthAndYear)

                                if !model.banks.isEmpty {
                    PickerDetailField(title: L10n.Localizable.KWPaymentMeanCreditCardIOS.bank,
                                      selection: $model.selectedBank,
                                      elements: model.banks) { bank in
                                        Text(bank?.name ?? L10n.Localizable.kwLinkedDefaultNone)
                    }

                }

                                PickerDetailField(title: L10n.Localizable.KWPaymentMeanCreditCardIOS.color,
                                  selection: $model.item.color,
                                  elements: CreditCardColor.allCases) { color in
                                    Text(color.localizedName)
                }

                                PickerDetailField(title: L10n.Localizable.KWPaymentMeanCreditCardIOS.linkedBillingAddress,
                                  selection: $model.selectedAddress,
                                  elements: model.addresses,
                                  allowEmptySelection: true) { address in
                                    Text(address?.name ?? L10n.Localizable.kwLinkedDefaultNone)
                }
            }
            .makeShortcuts(model: model)
        }
    }
}

private extension View {

    func makeShortcuts(model: CreditCardDetailViewModel) -> some View {
        self
            .mainMenuShortcut(.copyPrimary(title: L10n.Localizable.copyCardNumber),
                              enabled: !model.mode.isEditing && !model.item.cardNumber.isEmpty,
                              action: { model.copy(model.item.cardNumber, fieldType: .cardNumber) })
            .mainMenuShortcut(.copySecondary(title: L10n.Localizable.copySecurityCode),
                              enabled: !model.mode.isEditing && !model.item.securityCode.isEmpty,
                              action: { model.copy(model.item.securityCode, fieldType: .securityCode) })
    }
}

struct CreditCardDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            CreditCardDetailView(model: MockVaultConnectedContainer().makeCreditCardDetailViewModel(item: PersonalDataMock.CreditCards.personal, mode: .viewing))
            CreditCardDetailView(model: MockVaultConnectedContainer().makeCreditCardDetailViewModel(item: PersonalDataMock.CreditCards.personal, mode: .updating))
        }
    }
}
