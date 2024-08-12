import CoreLocalization
import CorePersonalData
import Foundation
import SwiftUI
import UIDelight
import VaultKit

struct PhoneDetailView: View {
  @StateObject var model: PhoneDetailViewModel

  init(model: @escaping @autoclosure () -> PhoneDetailViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    DetailContainerView(service: model.service) {
      Section {
        if model.mode.isEditing {
          TextDetailField(
            title: CoreLocalization.L10n.Core.KWPhoneIOS.phoneName, text: $model.item.name
          )
          .textInputAutocapitalization(.words)
        }

        PickerDetailField(
          title: CoreLocalization.L10n.Core.KWPhoneIOS.type,
          selection: $model.item.type,
          elements: Phone.NumberType.allCases.reversed(),
          content: { item in
            Text(item != nil ? item!.localizedString : L10n.Localizable.other)
          })

        TextDetailField(
          title: CoreLocalization.L10n.Core.KWPhoneIOS.number,
          text: $model.item.number,
          actions: [.copy(model.copy)]
        )
        .actions([.copy(model.copy)])
        .keyboardType(.numberPad)
        .fiberFieldType(.number)

        PickerDetailField(
          title: CoreLocalization.L10n.Core.KWPhoneIOS.localeFormat,
          selection: $model.item.country,
          elements: CountryCodeNamePair.countries,
          content: { country in
            Text(
              self.model.displayableCountry(
                forCountry: country != nil ? country! : CountryCodeNamePair.defaultCountry))

          })
      }
    }
  }
}

struct PhoneDetailView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview {
      PhoneDetailView(
        model: MockVaultConnectedContainer().makePhoneDetailViewModel(
          item: PersonalDataMock.Phones.personal, mode: .viewing))
      PhoneDetailView(
        model: MockVaultConnectedContainer().makePhoneDetailViewModel(
          item: PersonalDataMock.Phones.personal, mode: .updating))
    }
  }
}
