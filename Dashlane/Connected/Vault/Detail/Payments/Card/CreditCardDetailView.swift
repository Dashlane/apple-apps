import CoreLocalization
import CorePersonalData
import Foundation
import SwiftUI
import UIDelight
import VaultKit

struct CreditCardDetailView: View {
  @StateObject var model: CreditCardDetailViewModel

  init(model: @escaping @autoclosure () -> CreditCardDetailViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    DetailContainerView(service: model.service) {
      Section {
        if model.mode.isEditing {
          TextDetailField(
            title: CoreLocalization.L10n.Core.KWPaymentMeanCreditCardIOS.name,
            text: $model.item.name
          )
          .textInputAutocapitalization(.words)
        }

        PickerDetailField(
          title: CoreLocalization.L10n.Core.KWPaymentMeanCreditCardIOS.localeFormat,
          selection: $model.selectedCountry,
          elements: CountryCodeNamePair.countries
        ) { country in
          Text(country?.name ?? CountryCodeNamePair.defaultCountry.name)
        }

        TextDetailField(
          title: CoreLocalization.L10n.Core.KWPaymentMeanCreditCardIOS.ownerName,
          text: $model.item.ownerName
        )
        .textInputAutocapitalization(.words)

        SecureDetailField(
          title: CoreLocalization.L10n.Core.KWPaymentMeanCreditCardIOS.cardNumber,
          text: $model.item.cardNumber,
          shouldReveal: $model.shouldReveal,
          onRevealAction: model.reveal,
          formatter: CreditCardNumberFormatter(),
          obfuscatingFormatter: CreditCardNumberFormatter(obfuscate: true),
          actions: [.copy(model.copy)]
        )
        .actions([.copy(model.copy), .largeDisplay], accessHandler: model.requestAccess)
        .keyboardType(.numberPad)
        .fiberFieldType(.cardNumber)

        if model.mode.isEditing || !model.item.securityCode.isEmpty {
          SecureDetailField(
            title: CoreLocalization.L10n.Core.KWPaymentMeanCreditCardIOS.securityCode,
            text: $model.item.securityCode,
            shouldReveal: $model.shouldReveal,
            onRevealAction: model.reveal,
            hasDisplayEmptyIndicator: false,
            formatter: .uppercase,
            obfuscatingFormatter: .obfuscatedCode,
            actions: [.copy(model.copy)]
          )
          .actions([.copy(model.copy), .largeDisplay], accessHandler: model.requestAccess)
          .keyboardType(.numberPad)
          .fiberFieldType(.securityCode)
        }

        if model.mode.isEditing || !model.item.note.isEmpty {
          SecureDetailField(
            title: CoreLocalization.L10n.Core.KWPaymentMeanCreditCardIOS.ccNote,
            text: $model.item.note,
            shouldReveal: $model.shouldReveal,
            onRevealAction: model.reveal,
            hasDisplayEmptyIndicator: false,
            obfuscatingFormatter: .obfuscatedCode(max: 4),
            actions: [.copy(model.copy)]
          )
          .actions([.copy(model.copy), .largeDisplay], accessHandler: model.requestAccess)
          .fiberFieldType(.cCNote)
        }

        DateDetailField(
          title: CoreLocalization.L10n.Core.KWPaymentMeanCreditCardIOS.expiryDateForUi,
          date: $model.item.editableExpireDate,
          formatter: CreditCard.expireDateFormatter,
          range: DateRange.future,
          mode: .monthAndYear)

        if !model.banks.isEmpty {
          PickerDetailField(
            title: CoreLocalization.L10n.Core.KWPaymentMeanCreditCardIOS.bank,
            selection: $model.selectedBank,
            elements: model.banks
          ) { bank in
            Text(bank?.name ?? L10n.Localizable.kwLinkedDefaultNone)
          }

        }

        PickerDetailField(
          title: CoreLocalization.L10n.Core.KWPaymentMeanCreditCardIOS.color,
          selection: $model.item.color,
          elements: CreditCardColor.allCases,
          content: { color in
            HStack {
              Circle()
                .fill(color.color)
                .frame(width: 12)
              Text(color.localizedName)
            }
          }
        )

        PickerDetailField(
          title: CoreLocalization.L10n.Core.KWPaymentMeanCreditCardIOS.linkedBillingAddress,
          selection: $model.selectedAddress,
          elements: model.addresses,
          allowEmptySelection: true
        ) { address in
          Text(address?.name ?? L10n.Localizable.kwLinkedDefaultNone)
        }
      }
      .makeShortcuts(model: model)
    }
  }
}

extension View {

  fileprivate func makeShortcuts(model: CreditCardDetailViewModel) -> some View {
    self
      .mainMenuShortcut(
        .copyPrimary(title: L10n.Localizable.copyCardNumber),
        enabled: !model.mode.isEditing && !model.item.cardNumber.isEmpty,
        action: { model.copy(model.item.cardNumber, fieldType: .cardNumber) }
      )
      .mainMenuShortcut(
        .copySecondary(title: L10n.Localizable.copySecurityCode),
        enabled: !model.mode.isEditing && !model.item.securityCode.isEmpty,
        action: { model.copy(model.item.securityCode, fieldType: .securityCode) })
  }
}

struct CreditCardDetailView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview {
      CreditCardDetailView(
        model: MockVaultConnectedContainer().makeCreditCardDetailViewModel(
          item: PersonalDataMock.CreditCards.personal, mode: .viewing))
      CreditCardDetailView(
        model: MockVaultConnectedContainer().makeCreditCardDetailViewModel(
          item: PersonalDataMock.CreditCards.personal, mode: .updating))
    }
  }
}
