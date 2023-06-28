import SwiftUI
import CorePersonalData
import UIDelight
import VaultKit
import CoreLocalization

struct DrivingLicenseDetailView: View {

    @ObservedObject
    var model: DrivingLicenseDetailViewModel

    var body: some View {
        DetailContainerView(service: model.service) {
            Section {
                                if model.mode.isEditing {
                    PickerDetailField(title: CoreLocalization.L10n.Core.KWDriverLicenceIOS.localeFormat,
                                      selection: $model.item.country,
                                      elements: CountryCodeNamePair.countries,
                                      content: { country in
                                        Text(country?.name ?? "")
                    })
                } else {
                    Text(model.item.country?.name ?? CountryCodeNamePair.defaultCountry.name)
                        .labeled(CoreLocalization.L10n.Core.KWDriverLicenceIOS.localeFormat)
                }

                                if model.mode.isEditing {
                    PickerDetailField(title: CoreLocalization.L10n.Core.KWDriverLicenceIOS.linkedIdentity,
                                      selection: $model.item.linkedIdentity,
                                      elements: model.identities,
                                      allowEmptySelection: true,
                                      content: { identity in
                                        Text(identity?.displayName ?? L10n.Localizable.other)
                                      })
                }

                                if !model.mode.isEditing {
                    Text(model.displayFullName).labeled(CoreLocalization.L10n.Core.KWDriverLicenceIOS.fullname)
                }

                if model.item.linkedIdentity == nil {
                    if model.mode.isEditing {
                                                TextDetailField(title: CoreLocalization.L10n.Core.KWDriverLicenceIOS.fullname,
                                        text: $model.item.fullname)

                                                PickerDetailField(title: CoreLocalization.L10n.Core.KWDriverLicenceIOS.sex,
                                          selection: $model.item.sex,
                                          elements: Gender.allCases,
                                          content: { gender in
                                            Text(gender?.localized ?? "")
                        })
                    } else if model.item.sex != nil {
                        Text(model.item.genderString).labeled(CoreLocalization.L10n.Core.KWDriverLicenceIOS.sex)
                    }
                }

                                if model.mode.isEditing || !model.item.number.isEmpty {
                    TextDetailField(
                        title: CoreLocalization.L10n.Core.KWDriverLicenceIOS.number,
                        text: $model.item.number,
                        actions: [.copy(model.copy)]
                    )
                    .actions([.copy(model.copy)])
                    .fiberFieldType(.number)
                }

                                if model.item.mode == .countryWithState {
                    if model.mode.isEditing {
                        PickerDetailField(title: CoreLocalization.L10n.Core.KWDriverLicenceIOS.state,
                                          selection: $model.item.state,
                                          elements: model.stateItems,
                                          content: { country in
                                            Text(country?.name ?? "")
                        })
                        .textInputAutocapitalization(.words)
                    } else if model.item.state != nil {
                        Text(model.item.state?.name ?? "").labeled(CoreLocalization.L10n.Core.KWDriverLicenceIOS.state)
                    }
                }

                                DateDetailField(title: CoreLocalization.L10n.Core.KWDriverLicenceIOS.deliveryDate,
                                date: $model.item.deliveryDate,
                                range: .past)

                                DateDetailField(title: CoreLocalization.L10n.Core.KWPassportIOS.expireDate,
                                date: $model.item.expireDate,
                                range: .future)
            }.makeShortcuts(model: model)
        }
    }
}

private extension View {

    func makeShortcuts(model: DrivingLicenseDetailViewModel) -> some View {
        self
            .mainMenuShortcut(.copyPrimary(title: L10n.Localizable.kwCopyDriverLicenseNumberButton),
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
            DrivingLicenseDetailView(model: MockVaultConnectedContainer().makeDrivingLicenseDetailViewModel(item: PersonalDataMock.DrivingLicences.personal, mode: .viewing))
            DrivingLicenseDetailView(model: MockVaultConnectedContainer().makeDrivingLicenseDetailViewModel(item: PersonalDataMock.DrivingLicences.personal, mode: .updating))
            DrivingLicenseDetailView(model: MockVaultConnectedContainer().makeDrivingLicenseDetailViewModel(item: drivingLicenseIdentity, mode: .updating))
        }
    }
}
