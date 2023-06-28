import CoreLocalization
import DesignSystem
import SwiftUI
import UIComponents

public struct NotesDetailField: DetailField {

    public let title: String

    @Binding
    var text: String

    var isEditable: Bool

    @FocusState
    var isEditing

    @Environment(\.detailMode)
    var detailMode

    @Environment(\.detailFieldType)
    public var fiberFieldType

    public init(
        title: String,
        text: Binding<String>,
        isEditable: Bool
    ) {
        self.title = title
        self._text = text
        self.isEditable = isEditable
    }

    public var body: some View {
        TextEditor(text: $text)
            .focused($isEditing)
            .disabled(!isEditable)
            .multilineTextAlignment(.leading)
            .frame(minHeight: 30) 
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()

                    Button(L10n.Core.kwDoneButton) {
                        isEditing = false
                    }
                    .foregroundColor(.ds.text.brand.standard)
                    .font(.body.bold())
                }
            }
    }

}
