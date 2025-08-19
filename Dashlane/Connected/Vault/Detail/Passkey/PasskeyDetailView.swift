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
            title: CoreL10n.KWAuthentifiantIOS.title,
            text: $model.item.title,
            placeholder: CoreL10n.KWAuthentifiantIOS.Title.placeholder
          )
          .textInputAutocapitalization(.words)
        }

        TextDetailField(
          title: usernameFieldTitle,
          text: .constant(model.item.userDisplayName),
          actions: [.copy(model.copy)]
        )
        .actions([.copy(model.copy)])
        .fieldEditionDisabled(appearance: model.mode.isEditing ? .emphasized : .discrete)
      }

      Section(header: Text(CoreL10n.KWAuthentifiantIOS.urlStringForUI)) {
        if model.mode.isEditing {
          DS.TextField(
            CoreL10n.KWAuthentifiantIOS.url,
            text: .constant(
              "\(model.item.relyingPartyId.displayedScheme)\(model.item.relyingPartyId.displayDomain)"
            )
          )
          .fieldEditionDisabled()
          .textFieldColorHighlightingMode(.url)
          .lineLimit(1)
        } else {
          URLLinkDetailField(personalDataURL: model.item.relyingPartyId, onOpenURL: {})
        }
      }

      if model.mode.isEditing || !model.item.note.isEmpty {
        Section {
          NotesDetailField(
            title: CoreL10n.KWAuthentifiantIOS.note,
            text: $model.item.note
          )
          .actions([.copy(model.copy)], hasAccessory: false)
          .limitedRights(item: model.item, isFrozen: model.service.isFrozen)
          .fiberFieldType(.note)
        }
      }
    }
  }

  var usernameFieldTitle: String {
    if model.isUsernameAnEmail {
      return CoreL10n.KWAuthentifiantIOS.email
    }
    return CoreL10n.KWAuthentifiantIOS.login
  }
}

struct PasskeyDetailView_Previews: PreviewProvider {
  static var previews: some View {
    PasskeyDetailView(
      model: MockVaultConnectedContainer().makePasskeyDetailViewModel(item: .github))
  }
}
