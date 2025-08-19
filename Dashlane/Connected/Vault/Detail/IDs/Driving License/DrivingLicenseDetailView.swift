import CoreLocalization
import CorePersonalData
import DesignSystem
import SwiftUI
import UIDelight
import VaultKit

struct DrivingLicenseDetailView: View {
  @StateObject var model: DrivingLicenseDetailViewModel

  init(model: @escaping @autoclosure () -> DrivingLicenseDetailViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    DetailContainerView(service: model.service) {
      Section {
        if model.mode.isEditing {
          PickerDetailField(
            title: CoreL10n.KWDriverLicenceIOS.localeFormat,
            selection: $model.item.country,
            elements: CountryCodeNamePair.countries,
            content: { country in
              Text(country?.name ?? "")
            })
        } else {
          DS.DisplayField(
            CoreL10n.KWDriverLicenceIOS.localeFormat,
            text: model.item.country?.name ?? CountryCodeNamePair.defaultCountry.name)
        }

        if model.mode.isEditing {
          PickerDetailField(
            title: CoreL10n.KWDriverLicenceIOS.linkedIdentity,
            selection: $model.item.linkedIdentity,
            elements: model.identities,
            allowEmptySelection: true,
            content: { identity in
              Text(identity?.displayName ?? L10n.Localizable.other)
            })
        }

        if !model.mode.isEditing {
          DS.DisplayField(CoreL10n.KWDriverLicenceIOS.fullname, text: model.displayFullName)
        }

        if model.item.linkedIdentity == nil {
          if model.mode.isEditing {
            TextDetailField(
              title: CoreL10n.KWDriverLicenceIOS.fullname,
              text: $model.item.fullname)

            PickerDetailField(
              title: CoreL10n.KWDriverLicenceIOS.sex,
              selection: $model.item.sex,
              elements: Gender.allCases,
              content: { gender in
                Text(gender?.localized ?? "")
              })
          } else if model.item.sex != nil {
            DS.DisplayField(CoreL10n.KWDriverLicenceIOS.sex, text: model.item.genderString)
          }
        }

        if model.mode.isEditing || !model.item.number.isEmpty {
          TextDetailField(
            title: CoreL10n.KWDriverLicenceIOS.number,
            text: $model.item.number,
            actions: [.copy(model.copy)]
          )
          .actions([.copy(model.copy)])
          .fiberFieldType(.number)
        }

        if model.item.mode == .countryWithState {
          if model.mode.isEditing {
            PickerDetailField(
              title: CoreL10n.KWDriverLicenceIOS.state,
              selection: $model.item.state,
              elements: model.stateItems,
              content: { country in
                Text(country?.name ?? "")
              }
            )
            .textInputAutocapitalization(.words)
          } else if model.item.state != nil {
            DisplayField(
              CoreL10n.KWDriverLicenceIOS.state,
              text: model.item.state?.name ?? "")
          }
        }

        DateDetailField(
          title: CoreL10n.KWDriverLicenceIOS.deliveryDate,
          date: $model.item.deliveryDate,
          range: .past)

        DateDetailField(
          title: CoreL10n.KWPassportIOS.expireDate,
          date: $model.item.expireDate,
          range: .future)
      }.makeShortcuts(model: model)
    }
  }
}

extension View {

  fileprivate func makeShortcuts(model: DrivingLicenseDetailViewModel) -> some View {
    self
      .mainMenuShortcut(
        .copyPrimary(title: L10n.Localizable.kwCopyDriverLicenseNumberButton),
        enabled: !model.mode.isEditing && !model.item.number.isEmpty,
        action: { model.copy(model.item.number, fieldType: .number) })
  }
}

struct DrivingLicenseDetailView_Previews: PreviewProvider {

  static let drivingLicenseIdentity: DrivingLicence = {
    var drivingLicense = PersonalDataMock.DrivingLicences.personal
    drivingLicense.linkedIdentity = PersonalDataMock.Identities.personal
    return drivingLicense
  }()

  static var previews: some View {
    MultiContextPreview {
      DrivingLicenseDetailView(
        model: MockVaultConnectedContainer().makeDrivingLicenseDetailViewModel(
          item: PersonalDataMock.DrivingLicences.personal, mode: .viewing))
      DrivingLicenseDetailView(
        model: MockVaultConnectedContainer().makeDrivingLicenseDetailViewModel(
          item: PersonalDataMock.DrivingLicences.personal, mode: .updating))
      DrivingLicenseDetailView(
        model: MockVaultConnectedContainer().makeDrivingLicenseDetailViewModel(
          item: drivingLicenseIdentity, mode: .updating))
    }
  }
}
