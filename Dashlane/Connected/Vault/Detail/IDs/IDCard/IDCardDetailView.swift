import SwiftUI
import CorePersonalData
import UIDelight
import VaultKit
import CoreLocalization

struct IDCardDetailView: View {

    @ObservedObject
    var model: IDCardDetailViewModel

    var body: some View {
        DetailContainerView(service: model.service) {
            Section {
                                if model.mode.isEditing {
                    PickerDetailField(title: CoreLocalization.L10n.Core.KWIDCardIOS.localeFormat,
                                      selection: $model.item.nationality,
                                      elements: CountryCodeNamePair.countries,
                                      content: { country in
                                        Text(country?.name ?? "")
                                      })
                } else {
                    Text(model.item.nationality?.name ?? CountryCodeNamePair.defaultCountry.name)
                        .labeled(CoreLocalization.L10n.Core.KWIDCardIOS.localeFormat)
                }

                                if model.mode.isEditing {
                    PickerDetailField(title: CoreLocalization.L10n.Core.KWIDCardIOS.linkedIdentity,
                                      selection: $model.item.linkedIdentity,
                                      elements: model.identities,
                                      allowEmptySelection: true,
                                      content: { identity in
                                        Text(identity?.displayName ?? L10n.Localizable.other)
                                      })
                }

                                if !model.mode.isEditing {
                    Text(model.displayFullName).labeled(CoreLocalization.L10n.Core.KWIDCardIOS.fullname)
                }

                if model.item.linkedIdentity == nil {
                                        if model.mode.isEditing {
                                                TextDetailField(title: CoreLocalization.L10n.Core.KWIDCardIOS.fullname,
                                        text: $model.item.fullName)

                        PickerDetailField(title: CoreLocalization.L10n.Core.KWIDCardIOS.sex,
                                          selection: $model.item.sex,
                                          elements: Gender.allCases,
                                          content: { gender in
                                            Text(gender?.localized ?? "")
                        })
                    } else if model.item.sex != nil {
                        Text(model.item.genderString).labeled(CoreLocalization.L10n.Core.KWIDCardIOS.sex)
                    }

                                        DateDetailField(title: CoreLocalization.L10n.Core.KWIDCardIOS.dateOfBirth,
                                    date: $model.item.dateOfBirth,
                                    range: .past)
                }

                                if model.mode.isEditing || !model.item.number.isEmpty {
                    TextDetailField(title: CoreLocalization.L10n.Core.KWIDCardIOS.number,
                                    text: $model.item.number,
                                    actions: [.copy(model.copy)]
                    )
                    .actions([.copy(model.copy)])
                    .fiberFieldType(.number)
                }

                                DateDetailField(title: CoreLocalization.L10n.Core.KWIDCardIOS.deliveryDate,
                                date: $model.item.deliveryDate,
                                range: .past)

                                DateDetailField(title: CoreLocalization.L10n.Core.KWIDCardIOS.expireDate,
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
