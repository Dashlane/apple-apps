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
          TextDetailField(title: CoreL10n.KWPaymentMeanCreditCardIOS.name, text: $model.item.name)
            .textInputAutocapitalization(.words)
        }

        PickerDetailField(
          title: CoreL10n.KWPaymentMeanCreditCardIOS.localeFormat,
          selection: $model.selectedCountry,
          elements: CountryCodeNamePair.countries
        ) { country in
          Text(country?.name ?? CountryCodeNamePair.defaultCountry.name)
        }

        TextDetailField(
          title: CoreL10n.KWPaymentMeanCreditCardIOS.ownerName, text: $model.item.ownerName
        )
        .textInputAutocapitalization(.words)

        SecureDetailField(
          title: CoreL10n.KWPaymentMeanCreditCardIOS.cardNumber,
          text: $model.item.cardNumber,
          onRevealAction: model.sendUsageLog,
          format: .cardNumber,
          actions: [.copy(model.copy)]
        )
        .actions([.copy(model.copy), .largeDisplay])
        .keyboardType(.numberPad)
        .fiberFieldType(.cardNumber)

        if model.mode.isEditing || !model.item.securityCode.isEmpty {
          SecureDetailField(
            title: CoreL10n.KWPaymentMeanCreditCardIOS.securityCode,
            text: $model.item.securityCode,
            onRevealAction: model.sendUsageLog,
            format: .obfuscated(),
            actions: [.copy(model.copy)]
          )
          .actions([.copy(model.copy), .largeDisplay])
          .keyboardType(.numberPad)
          .fiberFieldType(.securityCode)
        }

        if model.mode.isEditing || !model.item.note.isEmpty {
          SecureDetailField(
            title: CoreL10n.KWPaymentMeanCreditCardIOS.ccNote,
            text: $model.item.note,
            onRevealAction: model.sendUsageLog,
            format: .obfuscated(maxLength: 4),
            actions: [.copy(model.copy)]
          )
          .actions([.copy(model.copy), .largeDisplay])
          .fiberFieldType(.cCNote)
        }

        DateDetailField(
          title: CoreL10n.KWPaymentMeanCreditCardIOS.expiryDateForUi,
          date: $model.item.editableExpireDate,
          range: .future
        )
        .dateFieldStyle(.monthYear)

        if !model.banks.isEmpty {
          PickerDetailField(
            title: CoreL10n.KWPaymentMeanCreditCardIOS.bank,
            selection: $model.selectedBank,
            elements: model.banks
          ) { bank in
            Text(bank?.name ?? L10n.Localizable.kwLinkedDefaultNone)
          }

        }

        PickerDetailField(
          title: CoreL10n.KWPaymentMeanCreditCardIOS.color,
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
          title: CoreL10n.KWPaymentMeanCreditCardIOS.linkedBillingAddress,
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
