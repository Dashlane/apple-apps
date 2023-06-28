import Foundation
import SwiftUI
import UIDelight
import DesignSystem

public struct MultilineTitleDetailField: DetailField {
    @Binding
    var text: String
    var placeholder: String = ""

    @Environment(\.detailMode)
    var detailMode

    public init(text: Binding<String>, placeholder: String = "") {
        self._text = text
        self.placeholder = placeholder
    }

    public var body: some View {
        Group {
            textfield
                .font(.title)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
        }
    }

    var textfield: some View {
       TextField(placeholder, text: $text)
            .disabled(!detailMode.isEditing)
    }
}

struct MultilineTitleDetailField_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            VStack {
                MultilineTitleDetailField(text: .constant("test")).environment(\.detailMode, .viewing)
                MultilineTitleDetailField(text: .constant("test")).environment(\.detailMode, .updating)
            }
            .background(Color.ds.background.default)
        }.previewLayout(.sizeThatFits)
    }
}
