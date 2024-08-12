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
      titleField

      contentField
    }
  }

  private var titleField: some View {
    TextDetailField(
      title: CoreLocalization.L10n.Core.secretTitle,
      text: $model.item.title,
      placeholder: CoreLocalization.L10n.Core.KWAuthentifiantIOS.Title.placeholder
    )
    .limitedRights(hasInfoButton: false, item: model.item)
    .textInputAutocapitalization(.words)
  }

  @ViewBuilder
  private var contentField: some View {
    NotesDetailField(
      title: CoreLocalization.L10n.Core.secretContent,
      text: $model.item.content
    )
    .actions([.copy(model.copy)], hasAccessory: false)
    .limitedRights(hasInfoButton: false, item: model.item)
  }
}
