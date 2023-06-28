import SwiftUI
import CorePersonalData
import UIDelight
import VaultKit
import CoreLocalization

struct PassportDetailView: View {

    @ObservedObject
    var model: PassportDetailViewModel

    var body: some View {
        DetailContainerView(service: model.service) {
            Section {
                                if model.mode.isEditing {
                    PickerDetailField(title: CoreLocalization.L10n.Core.KWPassportIOS.localeFormat,
                                      selection: $model.item.country,
                                      elements: CountryCodeNamePair.countries,
                                      content: { country in
                                        Text(country?.name ?? "")
                    })
                } else {
                    Text(model.item.country?.name ?? CountryCodeNamePair.defaultCountry.name)
                        .labeled(CoreLocalization.L10n.Core.KWPassportIOS.localeFormat)
                }

                                if model.mode.isEditing {
                    PickerDetailField(title: CoreLocalization.L10n.Core.KWPassportIOS.linkedIdentity,
                                      selection: $model.item.linkedIdentity,
                                      elements: model.identities,
                                      allowEmptySelection: true,
                                      content: { identity in
                                        Text(identity?.displayName ?? L10n.Localizable.other)
                    })
                }

                                if !model.mode.isEditing {
                    Text(model.displayFullName).labeled(CoreLocalization.L10n.Core.KWPassportIOS.fullname)
                }

                if model.item.linkedIdentity == nil {
                    if model.mode.isEditing {
                                                TextDetailField(title: CoreLocalization.L10n.Core.KWPassportIOS.fullname,
                                        text: $model.item.fullname)

                                                PickerDetailField(title: CoreLocalization.L10n.Core.KWPassportIOS.sex,
                                          selection: $model.item.sex,
                                          elements: Gender.allCases,
                                          content: { gender in
                                            Text(gender?.localized ?? "")
                        })
                    } else if model.item.sex != nil {
                        Text(model.item.genderString).labeled(CoreLocalization.L10n.Core.KWPassportIOS.sex)
                    }

                                        DateDetailField(title: CoreLocalization.L10n.Core.KWPassportIOS.dateOfBirth,
                                    date: $model.item.dateOfBirth,
                                    range: .past)
                }

                                if model.mode.isEditing || !model.item.number.isEmpty {
                    TextDetailField(
                        title: CoreLocalization.L10n.Core.KWPassportIOS.number,
                        text: $model.item.number,
                        actions: [.copy(model.copy)]
                    )
                    .actions([.copy(model.copy)])
                    .fiberFieldType(.number)
                }

                                if model.mode.isEditing || !model.item.deliveryPlace.isEmpty {
                    TextDetailField(title: CoreLocalization.L10n.Core.KWPassportIOS.deliveryPlace,
                                    text: $model.item.deliveryPlace)
                }

                                DateDetailField(title: CoreLocalization.L10n.Core.KWPassportIOS.deliveryDate,
                                date: $model.item.deliveryDate,
                                range: .past)

                                DateDetailField(title: CoreLocalization.L10n.Core.KWPassportIOS.expireDate,
                                date: $model.item.expireDate,
                                range: .future)
            }
        }.makeShortcuts(model: model)
    }
}

private extension View {

    func makeShortcuts(model: PassportDetailViewModel) -> some View {
        self
            .mainMenuShortcut(.copyPrimary(title: L10n.Localizable.kwCopyPassportNumberButton),
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
            PassportDetailView(model: MockVaultConnectedContainer().makePassportDetailViewModel(item: PersonalDataMock.Passports.personal, mode: .viewing))
            PassportDetailView(model: MockVaultConnectedContainer().makePassportDetailViewModel(item: PersonalDataMock.Passports.personal, mode: .updating))
            PassportDetailView(model: MockVaultConnectedContainer().makePassportDetailViewModel(item: passportIdentity, mode: .updating))
        }
    }
}
