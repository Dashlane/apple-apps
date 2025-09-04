import CoreLocalization
import CorePersonalData
import DesignSystem
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
            title: CoreL10n.KWSocialSecurityStatementIOS.localeFormat,
            selection: $model.item.country,
            elements: CountryCodeNamePair.countries,
            content: { country in
              Text(country?.name ?? "")
            })
        } else {
          DS.DisplayField(
            CoreL10n.KWSocialSecurityStatementIOS.localeFormat,
            text: model.item.country?.name ?? CountryCodeNamePair.defaultCountry.name)
        }

        if model.mode.isEditing {
          PickerDetailField(
            title: CoreL10n.KWSocialSecurityStatementIOS.linkedIdentity,
            selection: $model.item.linkedIdentity,
            elements: model.identities,
            allowEmptySelection: true,
            content: { identity in
              Text(identity?.displayName ?? L10n.Localizable.other)
            })
        }

        if !model.mode.isEditing {
          DS.DisplayField(
            CoreL10n.KWSocialSecurityStatementIOS.socialSecurityFullname,
            text: model.displayFullName)
        }

        if model.item.linkedIdentity == nil {
          if model.mode.isEditing {
            TextDetailField(
              title: CoreL10n.KWSocialSecurityStatementIOS.socialSecurityFullname,
              text: $model.item.fullname)

            PickerDetailField(
              title: CoreL10n.KWSocialSecurityStatementIOS.sex,
              selection: $model.item.sex,
              elements: Gender.allCases,
              content: { gender in
                Text(gender?.localized ?? "")
              })
          } else if model.item.sex != nil {
            DS.DisplayField(
              CoreL10n.KWSocialSecurityStatementIOS.sex, text: model.item.genderString)
          }

          DateDetailField(
            title: CoreL10n.KWSocialSecurityStatementIOS.dateOfBirth,
            date: $model.item.dateOfBirth,
            range: .past)
        }

        SecureDetailField(
          title: CoreL10n.KWSocialSecurityStatementIOS.socialSecurityNumber,
          text: $model.item.number,
          onRevealAction: model.sendUsageLog,
          format: .obfuscated(),
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
