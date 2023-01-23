import CorePersonalData
import DashlaneAppKit
import SwiftUI

struct NotesSection: View {

    @ObservedObject
    var model: NotesSectionModel

    var body: some View {
        Section {
            NotesDetailField(
                title: L10n.Localizable.KWAuthentifiantIOS.note,
                text: $model.item.note,
                isEditable: model.mode == .updating
            )
            .actions([.copy(model.copy)], hasAccessory: false)
            .limitedRights(item: model.item)
            .labeled(L10n.Localizable.KWAuthentifiantIOS.note)
            .fiberFieldType(.note)
        }
    }
}
