import SwiftUI
import CorePersonalData
import UIDelight

struct IDCardDetailView: View {

    @ObservedObject
    var model: IDCardDetailViewModel

    var body: some View {
        DetailContainerView(service: model.service) {
            Section {
                                if model.mode.isEditing {
                    PickerDetailField(title: L10n.Localizable.KWIDCardIOS.localeFormat,
                                      selection: $model.item.nationality,
                                      elements: CountryCodeNamePair.countries,
                                      content: { country in
                                        Text(country?.name ?? "")
                                      })
                } else {
                    Text(model.item.nationality?.name ?? CountryCodeNamePair.defaultCountry.name)
                        .labeled(L10n.Localizable.KWIDCardIOS.localeFormat)
                }

                                if model.mode.isEditing {
                    PickerDetailField(title: L10n.Localizable.KWIDCardIOS.linkedIdentity,
                                      selection: $model.item.linkedIdentity,
                                      elements: model.identities,
                                      allowEmptySelection: true,
                                      content: { identity in
                                        Text(identity?.displayName ?? L10n.Localizable.other)
                                      })
                }

                                if !model.mode.isEditing {
                    Text(model.displayFullName).labeled(L10n.Localizable.KWIDCardIOS.fullname)
                }

                if model.item.linkedIdentity == nil {
                                        if model.mode.isEditing {
                                                TextDetailField(title: L10n.Localizable.KWIDCardIOS.fullname,
                                        text: $model.item.fullName)

                        PickerDetailField(title: L10n.Localizable.KWIDCardIOS.sex,
                                          selection: $model.item.sex,
                                          elements: Gender.allCases,
                                          content: { gender in
                                            Text(gender?.localized ?? "")
                        })
                    } else if model.item.sex != nil {
                        Text(model.item.genderString).labeled(L10n.Localizable.KWIDCardIOS.sex)
                    }

                                        DateDetailField(title: L10n.Localizable.KWIDCardIOS.dateOfBirth,
                                    date: $model.item.dateOfBirth,
                                    range: .past)
                }

                                if model.mode.isEditing || !model.item.number.isEmpty {
                    TextDetailField(title: L10n.Localizable.KWIDCardIOS.number,
                                    text: $model.item.number)
                        .actions([.copy(model.copy)])
                        .fiberFieldType(.number)
                }

                                DateDetailField(title: L10n.Localizable.KWIDCardIOS.deliveryDate,
                                date: $model.item.deliveryDate,
                                range: .past)

                                DateDetailField(title: L10n.Localizable.KWIDCardIOS.expireDate,
                                date: $model.item.expireDate,
                                range: .future)
            }
        }.makeShortcuts(model: model)
    }
}

private extension View {

    func makeShortcuts(model: IDCardDetailViewModel) -> some View {
        self
            .mainMenuShortcut(.copyPrimary(title: L10n.Localizable.kwCopyIdentityCardNumberButton),
                              enabled: !model.mode.isEditing && !model.item.number.isEmpty,
                              action: { model.copy(model.item.number, fieldType: .number) })
    }
}

struct IDCardDetailView_Previews: PreviewProvider {

    static let idCardLinkedIdentity: IDCard = {
        var idCard = PersonalDataMock.IDCards.personal
        idCard.linkedIdentity = PersonalDataMock.Identities.personal
        return idCard
    }()

    static var previews: some View {
        MultiContextPreview {
            IDCardDetailView(model: MockVaultConnectedContainer().makeIDCardDetailViewModel(item: PersonalDataMock.IDCards.personal, mode: .viewing))
            IDCardDetailView(model: MockVaultConnectedContainer().makeIDCardDetailViewModel(item: PersonalDataMock.IDCards.personal, mode: .updating))
            IDCardDetailView(model: MockVaultConnectedContainer().makeIDCardDetailViewModel(item: idCardLinkedIdentity, mode: .updating))
        }
    }
}
