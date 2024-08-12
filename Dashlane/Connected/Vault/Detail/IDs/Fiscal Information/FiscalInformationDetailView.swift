import CoreLocalization
import CorePersonalData
import SwiftUI
import UIDelight
import VaultKit

struct FiscalInformationDetailView: View {
  @StateObject var model: FiscalInformationDetailViewModel

  init(model: @escaping @autoclosure () -> FiscalInformationDetailViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    DetailContainerView(service: model.service) {
      Section {
        if model.mode.isEditing {
          PickerDetailField(
            title: CoreLocalization.L10n.Core.KWFiscalStatementIOS.localeFormat,
            selection: $model.item.country,
            elements: CountryCodeNamePair.countries,
            content: { country in
              Text(country != nil ? country!.name : CountryCodeNamePair.defaultCountry.name)
            })
        } else {
          Text(model.item.country?.name ?? CountryCodeNamePair.defaultCountry.name)
            .labeled(CoreLocalization.L10n.Core.KWFiscalStatementIOS.localeFormat)
        }

        TextDetailField(
          title: CoreLocalization.L10n.Core.KWFiscalStatementIOS.fiscalNumber,
          text: $model.item.fiscalNumber,
          actions: [.copy(model.copy)]
        )
        .actions([.copy(model.copy)])
        .fiberFieldType(.fiscalNumber)

        if model.item.mode == .franceAndBelgium {
          TextDetailField(
            title: CoreLocalization.L10n.Core.KWFiscalStatementIOS.teledeclarantNumber,
            text: $model.item.teledeclarationNumber)
        }
      }.makeShortcuts(model: model)
    }
  }
}

extension View {

  fileprivate func makeShortcuts(model: FiscalInformationDetailViewModel) -> some View {
    self
      .mainMenuShortcut(
        .copyPrimary(title: L10n.Localizable.kwCopyFiscalNumberButton),
        enabled: !model.mode.isEditing && !model.item.fiscalNumber.isEmpty,
        action: { model.copy(model.item.fiscalNumber, fieldType: .fiscalNumber) })
  }
}

struct FiscalInformationDetailView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview {
      FiscalInformationDetailView(
        model: MockVaultConnectedContainer().makeFiscalInformationDetailViewModel(
          item: PersonalDataMock.FiscalInformations.personal, mode: .viewing))
      FiscalInformationDetailView(
        model: MockVaultConnectedContainer().makeFiscalInformationDetailViewModel(
          item: PersonalDataMock.FiscalInformations.personal, mode: .updating))
    }
  }
}
