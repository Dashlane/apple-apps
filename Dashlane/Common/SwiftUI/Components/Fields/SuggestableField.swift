import SwiftUI
import UIDelight

struct SuggestableFieldModifier: ViewModifier {
    var value: Binding<String>

    let suggestions: [String]

    @Binding
    var showSuggestions: Bool

    @Environment(\.detailMode)
    var detailMode

    func body(content: Content) -> some View {
        HStack(alignment: .center, spacing: 4) {
            content
                .frame(maxWidth: .infinity)
            if detailMode.isEditing && !suggestions.isEmpty {
                Button(action: showSelector) {
                    Image(asset: FiberAsset.detailDisclosureButton)
                        .foregroundColor(Color(asset: FiberAsset.accentColor))
                }
                .frame(width: 30, height: 30)
                .fiberAccessibilityLabel(Text(L10n.Localizable.detailItemViewAccessibilitySelectEmail))

            }
        }
    }

    func showSelector() {
        #if !EXTENSION
                UIApplication.shared.endEditing()
        #endif
        self.showSuggestions = true
    }
}

extension View {
        func suggestion(value: Binding<String>, suggestions: [String], showSuggestions: Binding<Bool>) -> some View {
        return modifier(SuggestableFieldModifier(value: value, suggestions: suggestions, showSuggestions: showSuggestions))
    }
}

struct SuggestableField_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                TextDetailField(title: "title", text: .constant("text"))
                    .suggestion(value: .constant("ds"), suggestions: ["first", "second"], showSuggestions: .constant(false))
            }.environment(\.detailMode, .updating)
        }

    }
}
