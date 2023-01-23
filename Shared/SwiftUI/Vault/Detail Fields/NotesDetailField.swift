import DesignSystem
import SwiftUI

struct NotesDetailField: DetailField {

    let title: String

    @Binding
    var text: String

    var isEditable: Bool

    @FocusState
    var isEditing

    @Environment(\.detailMode)
    var detailMode

    @Environment(\.detailFieldType)
    var fiberFieldType

    var body: some View {
        TextEditor(text: $text)
            .focused($isEditing)
            .disabled(!isEditable)
            .multilineTextAlignment(.leading)
            .frame(minHeight: 30) 
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()

                    Button(L10n.Localizable.kwDoneButton) {
                        isEditing = false
                    }
                    .foregroundColor(.ds.text.brand.standard)
                    .font(.body.bold())
                }
            }
    }

}
