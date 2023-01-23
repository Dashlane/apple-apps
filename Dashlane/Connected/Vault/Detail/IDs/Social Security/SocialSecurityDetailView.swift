import SwiftUI
import CorePersonalData
import UIDelight

struct SocialSecurityDetailView: View {
    @ObservedObject
    var model: SocialSecurityDetailViewModel

    var body: some View {
        DetailContainerView(service: model.service) {
            Section {
                                if model.mode.isEditing {
                    PickerDetailField(title: L10n.Localizable.KWSocialSecurityStatementIOS.localeFormat,
                                      selection: $model.item.country,
                                      elements: CountryCodeNamePair.countries,
                                      content: { country in
                                        Text(country?.name ?? "")
                    })
                } else {
                    Text(model.item.country?.name ?? CountryCodeNamePair.defaultCountry.name)
                        .labeled(L10n.Localizable.KWSocialSecurityStatementIOS.localeFormat)
                }

                                if model.mode.isEditing {
                    PickerDetailField(title: L10n.Localizable.KWSocialSecurityStatementIOS.linkedIdentity,
                                      selection: $model.item.linkedIdentity,
                                      elements: model.identities,
                                      allowEmptySelection: true,
                                      content: { identity in
                                        Text(identity?.displayName ?? L10n.Localizable.other)
                    })
                }

                                if !model.mode.isEditing {
                    Text(model.displayFullName).labeled(L10n.Localizable.KWSocialSecurityStatementIOS.socialSecurityFullname)
                }

                if model.item.linkedIdentity == nil {
                    if model.mode.isEditing {
                                                TextDetailField(title: L10n.Localizable.KWSocialSecurityStatementIOS.socialSecurityFullname,
                                        text: $model.item.fullname)

                                                PickerDetailField(title: L10n.Localizable.KWSocialSecurityStatementIOS.sex,
                                          selection: $model.item.sex,
                                          elements: Gender.allCases,
                                          content: { gender in
                                            Text(gender?.localized ?? "")
                        })
                    } else if model.item.sex != nil {
                        Text(model.item.genderString).labeled(L10n.Localizable.KWSocialSecurityStatementIOS.sex)
                    }

                                        DateDetailField(title: L10n.Localizable.KWSocialSecurityStatementIOS.dateOfBirth,
                                    date: $model.item.dateOfBirth,
                                    range: .past)
                }

                                SecureDetailField(title: L10n.Localizable.KWSocialSecurityStatementIOS.socialSecurityNumber,
                                  text: $model.item.number,
                                  shouldReveal: $model.shouldReveal,
                                  action: model.reveal,
                                  usagelogSubType: .socialSecurityNumber)
                    .actions([.copy(model.copy), .largeDisplay],
                             accessHandler: model.requestAccess)
                    .fiberFieldType(.socialSecurityNumber)

            }
        }.makeShortcuts(model: model)
    }
}

private extension View {

    func makeShortcuts(model: SocialSecurityDetailViewModel) -> some View {
        self
            .mainMenuShortcut(.copyPrimary(title: L10n.Localizable.kwCopySocialSecurityNumberButton),
                              enabled: !model.mode.isEditing && !model.item.number.isEmpty) {
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
            SocialSecurityDetailView(model: MockVaultConnectedContainer().makeSocialSecurityDetailViewModel(item: PersonalDataMock.SocialSecurityInformations.us, mode: .viewing))
            SocialSecurityDetailView(model: MockVaultConnectedContainer().makeSocialSecurityDetailViewModel(item: PersonalDataMock.SocialSecurityInformations.us, mode: .updating))
            SocialSecurityDetailView(model: MockVaultConnectedContainer().makeSocialSecurityDetailViewModel(item: socialSecurityIdentity, mode: .updating))
        }
    }
}
