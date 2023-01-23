import SwiftUI
import UIDelight

struct TextDetailField: DetailField {
    let title: String

    @Binding
    var text: String

    @Binding
    var isFocused: Bool

    @FocusState
    private var internalFocusState: Bool

    @Environment(\.detailMode)
    var detailMode

    @Environment(\.detailFieldType)
    var fiberFieldType
    
    let placeholder: String
    let placeholderColor: UIColor?

    var shouldBeDisabled: Bool {
        return !detailMode.isEditing
    }

    init(title: String,
         text: Binding<String>,
         placeholder: String = "",
         placeholderColor: UIColor? = nil,
         isFocused: Binding<Bool>? = nil) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.placeholderColor = placeholderColor
        _isFocused = isFocused.flatMap(Binding<Bool>.init(projectedValue:)) ?? .constant(false)
    }

    @ViewBuilder
    var body: some View {
        textField
            .contentShape(Rectangle())
            .onTapGesture {
                guard detailMode.isEditing else  { return }
                self.internalFocusState = true
            }
            .onChange(of: isFocused) { newValue in
                internalFocusState = newValue
            }
            .onChange(of: internalFocusState) { newValue in
                isFocused = newValue
            }
    }

    var textField: some View {
        TextField(placeholder, text: $text)
            .textInputAutocapitalization(.never)
            .focused($internalFocusState)
            .disableAutocorrection(true)
            .disabled(shouldBeDisabled)
            .lineLimit(1)
            .labeled(title)
            .frame(maxWidth: .infinity)
            .fiberAccessibilityElement(children: .combine)
            .fiberAccessibilityLabel(Text("\(title): \(text)"))
            .fiberAccessibilityHint(!shouldBeDisabled ?  Text(L10n.Localizable.detailItemViewAccessibilityEditableHint) : Text(""))
    }
}

struct TextDetailField_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            VStack {
                TextDetailField(title: "Title", text: .constant("test")).environment(\.detailMode, .viewing)
                TextDetailField(title: "Title", text: .constant("test")).environment(\.detailMode, .updating)
                TextDetailField(title: "Title", text: .constant("")).environment(\.detailMode, .viewing)
                TextDetailField(title: "Title", text: .constant("")).environment(\.detailMode, .updating)
            }.background(Color(asset: FiberAsset.mainBackground))
        }.previewLayout(.sizeThatFits)
    }
}
