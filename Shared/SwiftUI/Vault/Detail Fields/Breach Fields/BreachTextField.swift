import Foundation
import SwiftUI
import UIDelight

struct BreachTextField: DetailField {
    let title: String

    @Binding
    var text: String

    @FocusState
    var isFocused: Bool

    @Environment(\.detailFieldType)
    var fiberFieldType
    
    let isUserInteractionEnabled: Bool

    init(title: String,
         text: Binding<String>,
         isUserInteractionEnabled: Bool = true) {
        self.title = title
        self._text = text
        self.isUserInteractionEnabled = isUserInteractionEnabled
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.footnote)
                .foregroundColor(Color(asset: FiberAsset.grey01))

            textField
                .contentShape(Rectangle())
                .disabled(!isUserInteractionEnabled)
                .onTapGesture {
                    self.isFocused = true
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(asset: FiberAsset.cellBackground))
    }

    var textField: some View {
        TextField("", text: $text)
            .textInputAutocapitalization(.never)
            .focused($isFocused)
            .disableAutocorrection(true)
            .lineLimit(1)
            .frame(maxWidth: .infinity)
    }
}

struct BreachTextField_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            VStack {
                BreachTextField(title: "Title", text: .constant("test"))
            }
        }.previewLayout(.sizeThatFits)
    }
}
