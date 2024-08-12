import CoreLocalization
import DesignSystem
import SwiftUI
import VaultKit

struct PasskeyDetailView: View {
  @StateObject var model: PasskeyDetailViewModel

  init(model: @escaping @autoclosure () -> PasskeyDetailViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    DetailContainerView(service: model.service) {
      Section {
        if model.mode.isEditing {
          TextDetailField(
            title: CoreLocalization.L10n.Core.KWAuthentifiantIOS.title,
            text: $model.item.title,
            placeholder: CoreLocalization.L10n.Core.KWAuthentifiantIOS.Title.placeholder
          )
          .textInputAutocapitalization(.words)
        }

        TextDetailField(
          title: usernameFieldTitle,
          text: .constant(model.item.userDisplayName),
          actions: [.copy(model.copy)]
        )
        .actions([.copy(model.copy)])
        .editionDisabled(appearance: model.mode.isEditing ? .emphasized : .discrete)
      }

      Section(header: Text(CoreLocalization.L10n.Core.KWAuthentifiantIOS.urlStringForUI)) {
        URLLinkDetailField(personalDataURL: model.item.relyingPartyId, onOpenURL: {})
          .editionDisabled(appearance: model.mode.isEditing ? .emphasized : .discrete)
      }

      if model.mode.isEditing || !model.item.note.isEmpty {
        Section {
          NotesDetailField(
            title: CoreLocalization.L10n.Core.KWAuthentifiantIOS.note,
            text: $model.item.note
          )
          .actions([.copy(model.copy)], hasAccessory: false)
          .limitedRights(item: model.item)
          .fiberFieldType(.note)
        }
      }
    }
  }

  var usernameFieldTitle: String {
    if model.isUsernameAnEmail {
      return CoreLocalization.L10n.Core.KWAuthentifiantIOS.email
    }
    return CoreLocalization.L10n.Core.KWAuthentifiantIOS.login
  }
}

struct PasskeyDetailView_Previews: PreviewProvider {
  static var previews: some View {
    PasskeyDetailView(
      model: MockVaultConnectedContainer().makePasskeyDetailViewModel(item: .github))
  }
}
