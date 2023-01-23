import Foundation
import SwiftUI
import CorePersonalData
import CoreLocalization
import UIDelight
import DashlaneAppKit
import VaultKit

struct AddressDetailView: View {
    @ObservedObject
    var model: AddressDetailViewModel

    init(model: AddressDetailViewModel) {
        self.model = model
    }

    var body: some View {
        DetailContainerView(service: model.service) {
                        Section {
                if model.mode.isEditing {
                    TextDetailField(title: L10n.Localizable.KWPersonalWebsiteIOS.name, text: $model.item.name)
                        .textInputAutocapitalization(.words)
                }

                if model.item.mode == .europe {
                    addressFull
                    zipCode
                    city
                } else if model.item.mode == .europeWithState {
                    addressFull
                    zipCode
                    city
                    state
                } else if model.item.mode == .japan {
                    zipCode
                    city
                    addressFull
                } else if model.item.mode == .asia {
                    addressFull
                    city
                    zipCode
                } else if model.item.mode == .unitedKingdom {
                    streetNumber
                    streetName
                    city
                    state
                    zipCode
                } else if model.item.mode == .northAmericaAndAustralasia {
                    addressFull
                    city
                    state
                    zipCode
                }
                PickerDetailField(title: L10n.Localizable.KWAddressIOS.country,
                                  selection: $model.selectedCountry,
                                  elements: CountryCodeNamePair.countries,
                                  content: { country in
                                    Text(country?.name ?? CountryCodeNamePair.defaultCountry.name)

                })
            }

                        Section {
                if !model.item.receiver.isEmpty || model.mode.isEditing {
                    TextDetailField(title: L10n.Localizable.KWAddressIOS.receiver, text: $model.item.receiver)
                }
                if !model.item.building.isEmpty || model.mode.isEditing {
                    TextDetailField(title: L10n.Localizable.KWAddressIOS.building, text: $model.item.building)
                }
                if !model.item.stairs.isEmpty || model.mode.isEditing {
                    TextDetailField(title: L10n.Localizable.KWAddressIOS.stairs, text: $model.item.stairs)
                }
                if !model.item.floor.isEmpty || model.mode.isEditing {
                    TextDetailField(title: L10n.Localizable.KWAddressIOS.floor, text: $model.item.floor)
                }
                if !model.item.door.isEmpty || model.mode.isEditing {
                    TextDetailField(title: L10n.Localizable.KWAddressIOS.door, text: $model.item.door)
                }
                if !model.item.digitCode.isEmpty || model.mode.isEditing {
                    TextDetailField(title: L10n.Localizable.KWAddressIOS.digitCode, text: $model.item.digitCode)
                }
            }

                        Section {
                PickerDetailField(title: L10n.Localizable.KWAddressIOS.linkedPhone,
                                  selection: $model.selectedPhone,
                                  elements: model.phoneList,
                                  allowEmptySelection: true) { phone in
                    Text(phone?.name ?? L10n.Localizable.kwLinkedDefaultNone).fontWeight(.medium) + Text(" \(phone?.displayPhone ?? "")")
                }
            }
        }
    }

    var addressFull: some View {
        TextDetailField(title: L10n.Localizable.KWAddressIOS.addressFull, text: $model.item.addressFull)
            .actions([.copy(model.copy)])
            .textInputAutocapitalization(.words)
            .fiberFieldType(.address)
    }

    var zipCode: some View {
        TextDetailField(title: CoreLocalization.L10n.Core.KWAddressIOS.zipCodeFieldTitle(for: model.item.stateVariant), text: $model.item.zipCode)
    }

    var city: some View {
        TextDetailField(title: L10n.Localizable.KWAddressIOS.city, text: $model.item.city)
            .textInputAutocapitalization(.words)
    }

    var state: some View {
        PickerDetailField(title: CoreLocalization.L10n.Core.KWAddressIOS.stateFieldTitle(for: model.item.stateVariant),
                          selection: $model.item.state,
                          elements: model.stateItems,
                          allowEmptySelection: true) { item in
            Text(item?.name ?? L10n.Localizable.kwLinkedDefaultNone)
        }
    }

    var streetNumber: some View {
        TextDetailField(title: L10n.Localizable.KWAddressIOS.streetNumber, text: $model.item.streetNumber)
    }

    var streetName: some View {
        TextDetailField(title: "Street name", text: $model.item.streetName)
            .textInputAutocapitalization(.words)
    }
}

struct AddressDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            AddressDetailView(model: MockVaultConnectedContainer().makeAddressDetailViewModel(item: PersonalDataMock.Addresses.home, mode: .viewing))
            AddressDetailView(model: MockVaultConnectedContainer().makeAddressDetailViewModel(item: PersonalDataMock.Addresses.home, mode: .updating))
        }
    }
}
