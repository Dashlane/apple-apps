import DesignSystem
import SwiftUI
import UIComponents
import VaultKit
import CoreLocalization

struct SecureNotesDetailFields: View {

    @ObservedObject
    var model: SecureNotesDetailFieldsModel

    var isEditingContent: FocusState<Bool>.Binding

    var body: some View {
        VStack(spacing: 0) {
            if model.mode.isEditing || !model.item.title.isEmpty {
                MultilineTitleDetailField(text: $model.item.title, placeholder: L10n.Localizable.kwSecureNoteTitle)
                    .padding(.horizontal, 5)
                    .frame(minHeight: 50)
                    .focused(isEditingContent)
                    .limitedRights(allowViewing: false, hasInfoButton: false, item: model.item)

                Divider()
                    .overlay(Color.ds.border.neutral.quiet.idle)
            }

            MultilineDetailTextView(
                text: $model.item.content,
                placeholder: CoreLocalization.L10n.Core.KWSecureNoteIOS.emptyContent,
                isEditable: model.mode.isEditing,
                isSelectable: model.canEdit
            )
            .limitedRights(allowViewing: false, hasInfoButton: false, item: model.item)
        }
    }
}
