import CoreLocalization
import DesignSystem
import SwiftTreats
import SwiftUI
import UIDelight
import VaultKit

struct SecretMainSection: View {
  @StateObject var model: SecretMainSectionModel

  init(model: @autoclosure @escaping () -> SecretMainSectionModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    Section {
      if model.mode.isEditing {
        titleField
      }

      contentField
    }
  }

  private var titleField: some View {
    TextDetailField(
      title: CoreL10n.secretTitle,
      text: $model.item.title,
      placeholder: CoreL10n.KWAuthentifiantIOS.Title.placeholder
    )
    .limitedRights(hasInfoButton: false, item: model.item, isFrozen: model.service.isFrozen)
    .textInputAutocapitalization(.words)
  }

  @ViewBuilder
  private var contentField: some View {
    NotesDetailField(
      title: CoreL10n.secretContent,
      text: $model.item.content
    )
    .actions([.copy(model.copy)], hasAccessory: false)
    .limitedRights(hasInfoButton: false, item: model.item, isFrozen: model.service.isFrozen)
  }
}
