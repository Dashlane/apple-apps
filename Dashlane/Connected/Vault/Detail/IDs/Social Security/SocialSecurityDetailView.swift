import CoreLocalization
import CorePersonalData
import SwiftUI
import UIDelight
import VaultKit

struct SocialSecurityDetailView: View {
  @StateObject var model: SocialSecurityDetailViewModel

  init(model: @escaping @autoclosure () -> SocialSecurityDetailViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    DetailContainerView(service: model.service) {
      Section {
        if model.mode.isEditing {
          PickerDetailField(
            title: CoreLocalization.L10n.Core.KWSocialSecurityStatementIOS.localeFormat,
            selection: $model.item.country,
            elements: CountryCodeNamePair.countries,
            content: { country in
              Text(country?.name ?? "")
            })
        } else {
          Text(model.item.country?.name ?? CountryCodeNamePair.defaultCountry.name)
            .labeled(CoreLocalization.L10n.Core.KWSocialSecurityStatementIOS.localeFormat)
        }

        if model.mode.isEditing {
          PickerDetailField(
            title: CoreLocalization.L10n.Core.KWSocialSecurityStatementIOS.linkedIdentity,
            selection: $model.item.linkedIdentity,
            elements: model.identities,
            allowEmptySelection: true,
            content: { identity in
              Text(identity?.displayName ?? L10n.Localizable.other)
            })
        }

        if !model.mode.isEditing {
          Text(model.displayFullName).labeled(
            CoreLocalization.L10n.Core.KWSocialSecurityStatementIOS.socialSecurityFullname)
        }

        if model.item.linkedIdentity == nil {
          if model.mode.isEditing {
            TextDetailField(
              title: CoreLocalization.L10n.Core.KWSocialSecurityStatementIOS.socialSecurityFullname,
              text: $model.item.fullname)

            PickerDetailField(
              title: CoreLocalization.L10n.Core.KWSocialSecurityStatementIOS.sex,
              selection: $model.item.sex,
              elements: Gender.allCases,
              content: { gender in
                Text(gender?.localized ?? "")
              })
          } else if model.item.sex != nil {
            Text(model.item.genderString).labeled(
              CoreLocalization.L10n.Core.KWSocialSecurityStatementIOS.sex)
          }

          DateDetailField(
            title: CoreLocalization.L10n.Core.KWSocialSecurityStatementIOS.dateOfBirth,
            date: $model.item.dateOfBirth,
            range: .past)
        }

        SecureDetailField(
          title: CoreLocalization.L10n.Core.KWSocialSecurityStatementIOS.socialSecurityNumber,
          text: $model.item.number,
          onRevealAction: model.sendUsageLog,
          actions: [.copy(model.copy)]
        )
        .actions([.copy(model.copy), .largeDisplay])
        .fiberFieldType(.socialSecurityNumber)
      }
    }
    .makeShortcuts(model: model)
  }
}

extension View {

  fileprivate func makeShortcuts(model: SocialSecurityDetailViewModel) -> some View {
    self
      .mainMenuShortcut(
        .copyPrimary(title: L10n.Localizable.kwCopySocialSecurityNumberButton),
        enabled: !model.mode.isEditing && !model.item.number.isEmpty
      ) {
        model.copy(model.item.number, fieldType: .number)
      }
  }
}

struct SocialSecurityDetailView_Previews: PreviewProvider {

  static let socialSecurityIdentity: SocialSecurityInformation = {
    var socialSecurity = PersonalDataMock.SocialSecurityInformations.us
    socialSecurity.linkedIdentity = PersonalDataMock.Identities.personal
    return socialSecurity
  }()

  static var previews: some View {
    MultiContextPreview {
      SocialSecurityDetailView(
        model: MockVaultConnectedContainer().makeSocialSecurityDetailViewModel(
          item: PersonalDataMock.SocialSecurityInformations.us, mode: .viewing))
      SocialSecurityDetailView(
        model: MockVaultConnectedContainer().makeSocialSecurityDetailViewModel(
          item: PersonalDataMock.SocialSecurityInformations.us, mode: .updating))
      SocialSecurityDetailView(
        model: MockVaultConnectedContainer().makeSocialSecurityDetailViewModel(
          item: socialSecurityIdentity, mode: .updating))
    }
  }
}
