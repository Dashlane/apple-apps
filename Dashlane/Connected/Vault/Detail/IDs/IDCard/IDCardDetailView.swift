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
          PickerDetailField(
            title: CoreL10n.KWIDCardIOS.localeFormat,
            selection: $model.item.nationality,
            elements: CountryCodeNamePair.countries,
            content: { country in
              Text(country?.name ?? "")
            })
        } else {
          DS.DisplayField(
            CoreL10n.KWIDCardIOS.localeFormat,
            text: model.item.nationality?.name ?? CountryCodeNamePair.defaultCountry.name
          )
        }

        if model.mode.isEditing {
          PickerDetailField(
            title: CoreL10n.KWIDCardIOS.linkedIdentity,
            selection: $model.item.linkedIdentity,
            elements: model.identities,
            allowEmptySelection: true,
            content: { identity in
              Text(identity?.displayName ?? L10n.Localizable.other)
            })
        }

        if !model.mode.isEditing {
          DS.DisplayField(
            CoreL10n.KWIDCardIOS.fullname,
            text: model.displayFullName
          )
        }

        if model.item.linkedIdentity == nil {
          if model.mode.isEditing {
            DS.TextField(
              CoreL10n.KWIDCardIOS.fullname,
              text: $model.item.fullName
            )

            PickerDetailField(
              title: CoreL10n.KWIDCardIOS.sex,
              selection: $model.item.sex,
              elements: Gender.allCases,
              content: { gender in
                Text(gender?.localized ?? "")
              })

          } else if model.item.sex != nil {
            DS.DisplayField(
              CoreL10n.KWIDCardIOS.sex,
              text: model.item.genderString
            )
          }

          DateDetailField(
            title: CoreL10n.KWIDCardIOS.dateOfBirth,
            date: $model.item.dateOfBirth,
            range: .past)
        }

        if model.mode.isEditing || !model.item.number.isEmpty {
          TextDetailField(
            title: CoreL10n.KWIDCardIOS.number,
            text: $model.item.number,
            actions: [.copy(model.copy)]
          )
          .actions([.copy(model.copy)])
          .fiberFieldType(.number)
        }

        DateDetailField(
          title: CoreL10n.KWIDCardIOS.deliveryDate,
          date: $model.item.deliveryDate,
          range: .past)

        DateDetailField(
          title: CoreL10n.KWIDCardIOS.expireDate,
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
