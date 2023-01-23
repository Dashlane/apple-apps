import Foundation
import SwiftUI
import CorePersonalData
import UIDelight

struct IdentityDetailView: View {
    @ObservedObject
    var model: IdentityDetailViewModel

    init(model: IdentityDetailViewModel) {
        self.model = model
    }

    var body: some View {
        DetailContainerView(service: model.service) {
            Section {
                                PickerDetailField(title: L10n.Localizable.KWIdentityIOS.title,
                                  selection: $model.item.personalTitle,
                                  elements: Identity.PersonalTitle.displayableCases,
                                  content: { item in
                    Text(item.localizedString)
                })

                                if !model.item.firstName.isEmpty || model.mode.isEditing {
                    TextDetailField(title: L10n.Localizable.KWIdentityIOS.firstName, text: $model.item.firstName)
                        .textInputAutocapitalization(.words)
                }

                                if !model.item.middleName.isEmpty || model.mode.isEditing {
                    TextDetailField(title: L10n.Localizable.KWIdentityIOS.middleName, text: $model.item.middleName)
                        .textInputAutocapitalization(.words)
                }

                                if !model.item.lastName.isEmpty || model.mode.isEditing {
                    TextDetailField(title: L10n.Localizable.KWIdentityIOS.lastName, text: $model.item.lastName)
                        .textInputAutocapitalization(.words)
                }

                                if !model.item.pseudo.isEmpty || model.mode.isEditing {
                    TextDetailField(title: L10n.Localizable.KWIdentityIOS.pseudo, text: $model.item.pseudo)
                        .textInputAutocapitalization(.words)
                }

                                DateDetailField(title: L10n.Localizable.KWIdentityIOS.birthDate,
                                date: $model.item.birthDate,
                                range: .past)

                                if !model.item.birthPlace.isEmpty || model.mode == .updating {
                    TextDetailField(title: L10n.Localizable.KWIdentityIOS.birthPlace, text: $model.item.birthPlace)
                }
            }
        }
    }
}

struct IdentityDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            IdentityDetailView(model: MockVaultConnectedContainer().makeIdentityDetailViewModel(item: PersonalDataMock.Identities.personal, mode: .viewing))
            IdentityDetailView(model: MockVaultConnectedContainer().makeIdentityDetailViewModel(item: PersonalDataMock.Identities.personal, mode: .updating))
        }
    }
}
