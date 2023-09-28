import SwiftUI
import DesignSystem

struct LabeledFieldModifier: ViewModifier {
    let label: String
    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .foregroundColor(.ds.text.neutral.quiet)
                .font(.caption)
                .id(label)
            content
        }
    }
}

extension View {
        public func labeled(_ label: String) -> some View {
        return modifier(LabeledFieldModifier(label: label))
    }
}

struct LabeledField_Previews: PreviewProvider {
    static var previews: some View {
        TextField("title", text: .constant("text"))
            .labeled("title")
    }
}
