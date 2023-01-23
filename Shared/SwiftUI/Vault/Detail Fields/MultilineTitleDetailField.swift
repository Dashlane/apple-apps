import Foundation
import SwiftUI
import UIDelight

struct MultilineTitleDetailField: DetailField {
    @Binding
    var text: String
    var placeholder: String = ""

    @Environment(\.detailMode)
    var detailMode

    var body: some View {
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
            }.background(Color(asset: FiberAsset.mainBackground))
        }.previewLayout(.sizeThatFits)
    }
}
