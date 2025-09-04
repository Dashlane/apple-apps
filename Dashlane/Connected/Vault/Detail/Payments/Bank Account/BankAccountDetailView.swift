import CoreLocalization
import CorePersonalData
import Foundation
import SwiftUI
import UIComponents
import UIDelight
import VaultKit

struct BankAccountDetailView: View {
  @StateObject var model: BankAccountDetailViewModel

  init(model: @escaping @autoclosure () -> BankAccountDetailViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    DetailContainerView(service: model.service) {
      Section {
        if model.mode.isEditing {
          TextDetailField(
            title: CoreL10n.KWBankStatementIOS.bankAccountName,
            text: $model.item.name,
            placeholder: CoreL10n.KWBankStatementIOS.BankAccountName.placeholder
          )
          .textInputAutocapitalization(.words)
        }

        PickerDetailField(
          title: CoreL10n.KWBankStatementIOS.localeFormat,
          selection: $model.selectedCountry,
          elements: CountryCodeNamePair.countries
        ) { country in
          Text(country?.name ?? CountryCodeNamePair.defaultCountry.name)
        }

        TextDetailField(
          title: CoreL10n.KWBankStatementIOS.bankAccountOwner, text: $model.item.owner
        )
        .textInputAutocapitalization(.words)

        SecureDetailField(
          title: CoreL10n.KWBankStatementIOS.bicFieldTitle(for: model.item.bicVariant),
          text: $model.item.bic,
          onRevealAction: model.sendUsageLog,
          format: .accountIdentifier(.bic),
          actions: [.copy(model.copy)]
        )
        .actions([.copy(model.copy), .largeDisplay])
        .textInputAutocapitalization(.characters)
        .fiberFieldType(.bankAccountBIC)

        SecureDetailField(
          title: CoreL10n.KWBankStatementIOS.ibanFieldTitle(for: model.item.ibanVariant),
          text: $model.item.iban,
          onRevealAction: model.sendUsageLog,
          format: .accountIdentifier(.iban),
          actions: [.copy(model.copy)]
        )
        .actions([.copy(model.copy), .largeDisplay])
        .textInputAutocapitalization(.characters)
        .fiberFieldType(.bankAccountIBAN)

        if !model.banks.isEmpty {
          PickerDetailField(
            title: CoreL10n.KWBankStatementIOS.bankAccountBank,
            selection: $model.selectedBank,
            elements: model.banks
          ) { bank in
            Text(bank?.name ?? CoreL10n.kwLinkedDefaultOther)
          }
        }
      }
      .makeShortcuts(model: model)
    }
  }
}

extension View {
  fileprivate func makeShortcuts(model: BankAccountDetailViewModel) -> some View {
    self
      .mainMenuShortcut(
        .copyPrimary(title: L10n.Localizable.copyIBAN),
        enabled: !model.mode.isEditing && !model.item.iban.isEmpty,
        action: { model.copy(model.item.iban, fieldType: .bankAccountIBAN) }
      )
      .mainMenuShortcut(
        .copySecondary(title: L10n.Localizable.copyBic),
        enabled: !model.mode.isEditing && !model.item.bic.isEmpty,
        action: { model.copy(model.item.bic, fieldType: .bankAccountBIC) }
      )
  }
}

#Preview("Viewing mode") {
  BankAccountDetailView(
    model: MockVaultConnectedContainer().makeBankAccountDetailViewModel(
      item: PersonalDataMock.BankAccounts.personal,
      mode: .viewing
    )
  )
}

#Preview("Updating mode") {
  BankAccountDetailView(
    model: MockVaultConnectedContainer().makeBankAccountDetailViewModel(
      item: PersonalDataMock.BankAccounts.personal,
      mode: .updating
    )
  )
}
