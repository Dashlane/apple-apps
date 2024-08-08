import CoreLocalization
import CorePersonalData
import DesignSystem
import SwiftUI
import UIDelight
import VaultKit

struct IDCardDetailView: View {
  @StateObject var model: IDCardDetailViewModel

  init(model: @escaping @autoclosure () -> IDCardDetailViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    DetailContainerView(service: model.service) {
      Section {
        if model.mode.isEditing {
          DS.Select(
            CoreLocalization.L10n.Core.KWIDCardIOS.localeFormat,
            values: CountryCodeNamePair.countries,
            selection: $model.item.nationality,
            textualRepresentation: \.name
          ) { country in
            Text(country.name)
          }
        } else {
          DS.DisplayField(
            CoreLocalization.L10n.Core.KWIDCardIOS.localeFormat,
            text: model.item.nationality?.name ?? CountryCodeNamePair.defaultCountry.name
          )
        }

        if model.mode.isEditing {
          DS.Select(
            CoreLocalization.L10n.Core.KWIDCardIOS.linkedIdentity,
            values: model.identities,
            selection: $model.item.linkedIdentity,
            textualRepresentation: \.displayName,
            unspecifiedValueOptionLabel: L10n.Localizable.other
          ) { identity in
            Text(identity.displayName)
          }
        }

        if !model.mode.isEditing {
          DS.DisplayField(
            CoreLocalization.L10n.Core.KWIDCardIOS.fullname,
            text: model.displayFullName
          )
        }

        if model.item.linkedIdentity == nil {
          if model.mode.isEditing {
            DS.TextField(
              CoreLocalization.L10n.Core.KWIDCardIOS.fullname,
              text: $model.item.fullName
            )

            DS.Select(
              CoreLocalization.L10n.Core.KWIDCardIOS.sex,
              values: Gender.allCases,
              selection: $model.item.sex,
              textualRepresentation: \.localized
            ) { gender in
              Text(gender.localized)
            }
          } else if model.item.sex != nil {
            DS.DisplayField(
              CoreLocalization.L10n.Core.KWIDCardIOS.sex,
              text: model.item.genderString
            )
          }

          DateDetailField(
            title: CoreLocalization.L10n.Core.KWIDCardIOS.dateOfBirth,
            date: $model.item.dateOfBirth,
            range: .past)
        }

        if model.mode.isEditing || !model.item.number.isEmpty {
          TextDetailField(
            title: CoreLocalization.L10n.Core.KWIDCardIOS.number,
            text: $model.item.number,
            actions: [.copy(model.copy)]
          )
          .actions([.copy(model.copy)])
          .fiberFieldType(.number)
        }

        DateDetailField(
          title: CoreLocalization.L10n.Core.KWIDCardIOS.deliveryDate,
          date: $model.item.deliveryDate,
          range: .past)

        DateDetailField(
          title: CoreLocalization.L10n.Core.KWIDCardIOS.expireDate,
          date: $model.item.expireDate,
          range: .future)
      }
    }
    .makeShortcuts(model: model)
  }
}

extension View {
  fileprivate func makeShortcuts(model: IDCardDetailViewModel) -> some View {
    self
      .mainMenuShortcut(
        .copyPrimary(title: L10n.Localizable.kwCopyIdentityCardNumberButton),
        enabled: !model.mode.isEditing && !model.item.number.isEmpty,
        action: { model.copy(model.item.number, fieldType: .number) }
      )
  }
}

extension IDCard {
  fileprivate func with<T>(_ property: WritableKeyPath<Self, T>, value: T) -> Self {
    var copy = self
    copy[keyPath: property] = value
    return copy
  }
}

#Preview("Viewing") {
  IDCardDetailView(
    model: MockVaultConnectedContainer().makeIDCardDetailViewModel(
      item: PersonalDataMock.IDCards.personal,
      mode: .viewing
    )
  )
}

#Preview("Updating") {
  IDCardDetailView(
    model: MockVaultConnectedContainer().makeIDCardDetailViewModel(
      item: PersonalDataMock.IDCards.personal,
      mode: .updating
    )
  )
}

#Preview("[LinkedIdentity] Viewing") {
  IDCardDetailView(
    model: MockVaultConnectedContainer().makeIDCardDetailViewModel(
      item: PersonalDataMock.IDCards.personal.with(
        \.linkedIdentity,
        value: PersonalDataMock.Identities.personal
      ),
      mode: .viewing
    )
  )
}

#Preview("[LinkedIdentity] Updating") {
  IDCardDetailView(
    model: MockVaultConnectedContainer().makeIDCardDetailViewModel(
      item: PersonalDataMock.IDCards.personal.with(
        \.linkedIdentity,
        value: PersonalDataMock.Identities.personal
      ),
      mode: .updating
    )
  )
}
