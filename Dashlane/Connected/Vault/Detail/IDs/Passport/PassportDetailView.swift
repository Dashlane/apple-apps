import CoreLocalization
import CorePersonalData
import DesignSystem
import SwiftUI
import UIDelight
import VaultKit

struct PassportDetailView: View {
  @StateObject var model: PassportDetailViewModel

  init(model: @escaping @autoclosure () -> PassportDetailViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    DetailContainerView(service: model.service) {
      Section {
        if model.mode.isEditing {
          PickerDetailField(
            title: CoreL10n.KWPassportIOS.localeFormat,
            selection: $model.item.country,
            elements: CountryCodeNamePair.countries,
            content: { country in
              Text(country?.name ?? "")
            })
        } else {
          DisplayField(
            CoreL10n.KWPassportIOS.localeFormat,
            text: model.item.country?.name ?? CountryCodeNamePair.defaultCountry.name)
        }

        if model.mode.isEditing {
          PickerDetailField(
            title: CoreL10n.KWPassportIOS.linkedIdentity,
            selection: $model.item.linkedIdentity,
            elements: model.identities,
            allowEmptySelection: true,
            content: { identity in
              Text(identity?.displayName ?? L10n.Localizable.other)
            })
        }

        if !model.mode.isEditing {
          DisplayField(CoreL10n.KWPassportIOS.fullname, text: model.displayFullName)
        }

        if model.item.linkedIdentity == nil {
          if model.mode.isEditing {
            TextDetailField(
              title: CoreL10n.KWPassportIOS.fullname,
              text: $model.item.fullname
            )
            .foregroundStyle(Color.ds.text.neutral.catchy)

            PickerDetailField(
              title: CoreL10n.KWPassportIOS.sex,
              selection: $model.item.sex,
              elements: Gender.allCases,
              content: { gender in
                Text(gender?.localized ?? "")
              })
          } else if model.item.sex != nil {
            DisplayField(CoreL10n.KWPassportIOS.sex, text: model.item.genderString)
          }

          DateDetailField(
            title: CoreL10n.KWPassportIOS.dateOfBirth,
            date: $model.item.dateOfBirth,
            range: .past)
        }

        if model.mode.isEditing || !model.item.number.isEmpty {
          TextDetailField(
            title: CoreL10n.KWPassportIOS.number,
            text: $model.item.number,
            actions: [.copy(model.copy)]
          )
          .actions([.copy(model.copy)])
          .fiberFieldType(.number)
        }

        if model.mode.isEditing || !model.item.deliveryPlace.isEmpty {
          TextDetailField(
            title: CoreL10n.KWPassportIOS.deliveryPlace,
            text: $model.item.deliveryPlace)
        }

        DateDetailField(
          title: CoreL10n.KWPassportIOS.deliveryDate,
          date: $model.item.deliveryDate,
          range: .past)

        DateDetailField(
          title: CoreL10n.KWPassportIOS.expireDate,
          date: $model.item.expireDate,
          range: .future)
      }
    }.makeShortcuts(model: model)
  }
}

extension View {

  fileprivate func makeShortcuts(model: PassportDetailViewModel) -> some View {
    self
      .mainMenuShortcut(
        .copyPrimary(title: L10n.Localizable.kwCopyPassportNumberButton),
        enabled: !model.mode.isEditing && !model.item.number.isEmpty,
        action: { model.copy(model.item.number, fieldType: .number) })
  }
}

struct PassportDetailView_Previews: PreviewProvider {

  static let passportIdentity: Passport = {
    var passport = PersonalDataMock.Passports.personal
    passport.linkedIdentity = PersonalDataMock.Identities.personal
    return passport
  }()

  static var previews: some View {
    MultiContextPreview {
      PassportDetailView(
        model: MockVaultConnectedContainer().makePassportDetailViewModel(
          item: PersonalDataMock.Passports.personal, mode: .viewing))
      PassportDetailView(
        model: MockVaultConnectedContainer().makePassportDetailViewModel(
          item: PersonalDataMock.Passports.personal, mode: .updating))
      PassportDetailView(
        model: MockVaultConnectedContainer().makePassportDetailViewModel(
          item: passportIdentity, mode: .updating))
    }
  }
}
