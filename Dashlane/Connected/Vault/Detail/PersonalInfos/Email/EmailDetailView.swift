import Foundation
import SwiftUI
import CorePersonalData
import UIDelight

struct EmailDetailView: View {
    @ObservedObject
    var model: EmailDetailViewModel

    init(model: EmailDetailViewModel) {
        self.model = model
    }

    var body: some View {
        DetailContainerView(service: model.service) {
            Section {
                if model.mode.isEditing {
                    TextDetailField(title: L10n.Localizable.KWEmailIOS.emailName, text: $model.item.name)
                        .textInputAutocapitalization(.words)
                }
                TextDetailField(title: L10n.Localizable.KWEmailIOS.email,
                                text: $model.item.value)
                    .actions([.copy(model.copy)])
                    .keyboardType(.emailAddress)
                    .fiberFieldType(.email)
                PickerDetailField(title: L10n.Localizable.KWEmailIOS.type,
                                  selection: $model.item.type,
                                  elements: Email.EmailType.allCases,
                                  content: { item in
                                    Text((item != nil ? item! : Email.EmailType.defaultValue).localizedString)
                })
            }
        }
    }
}

struct EmailDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            EmailDetailView(model: MockVaultConnectedContainer().makeEmailDetailViewModel(item: PersonalDataMock.Emails.personal, mode: .viewing))
            EmailDetailView(model: MockVaultConnectedContainer().makeEmailDetailViewModel(item: PersonalDataMock.Emails.personal, mode: .updating))
        }
    }
}
