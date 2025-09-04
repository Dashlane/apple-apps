import CoreLocalization
import CorePersonalData
import SwiftUI
import VaultKit

struct NotesSection: View {
  @StateObject var model: NotesSectionModel

  init(model: @escaping @autoclosure () -> NotesSectionModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
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
