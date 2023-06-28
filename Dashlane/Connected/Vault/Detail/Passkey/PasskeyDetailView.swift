import SwiftUI
import VaultKit
import CoreLocalization

struct PasskeyDetailView: View {

    @ObservedObject
    var model: PasskeyDetailViewModel

    init(model: PasskeyDetailViewModel) {
        self.model = model
    }

    var body: some View {
        DetailContainerView(service: model.service) {
            Section {
                TextDetailField(
                    title: CoreLocalization.L10n.Core.KWAuthentifiantIOS.title,
                    text: $model.item.title,
                    placeholder: CoreLocalization.L10n.Core.KWAuthentifiantIOS.Title.placeholder
                )
                .textInputAutocapitalization(.words)
                if !model.mode.isEditing {
                    TextDetailField(title: CoreLocalization.L10n.Core.KWAuthentifiantIOS.url,
                                    text: .constant(model.item.relyingPartyName))

                    TextDetailField(title: CoreLocalization.L10n.Core.KWAuthentifiantIOS.login,
                                    text: .constant(model.item.userDisplayName),
                                    actions: [.copy(model.copy)])
                    .actions([.copy(model.copy)])
                }

            }
            Section {
                NotesDetailField(
                    title: CoreLocalization.L10n.Core.KWAuthentifiantIOS.note,
                    text: $model.item.note,
                    isEditable: model.mode == .updating
                )
                .actions([.copy(model.copy)], hasAccessory: false)
                .limitedRights(item: model.item)
                .labeled(CoreLocalization.L10n.Core.KWAuthentifiantIOS.note)
                .fiberFieldType(.note)
            }
        }
    }
}

struct PasskeyDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PasskeyDetailView(model: MockVaultConnectedContainer().makePasskeyDetailViewModel(item: .github))
    }
}
