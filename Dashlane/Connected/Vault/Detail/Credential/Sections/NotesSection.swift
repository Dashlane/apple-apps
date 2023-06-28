import CorePersonalData
import DashlaneAppKit
import SwiftUI
import VaultKit
import CoreLocalization

struct NotesSection: View {

    @ObservedObject
    var model: NotesSectionModel

    var body: some View {
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
