import SwiftUI

public struct TextFieldTextualFeedback: View {
    @Environment(\.textFieldFeedbackAppearance) private var feedbackAppearance
    private let text: String

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(verbatim: text)
            .foregroundColor(.textForegroundColor(for: feedbackAppearance))
            .textStyle(.body.helper.regular)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }
}

private extension Color {
    static func textForegroundColor(for feedbackAppearance: TextFieldFeedbackAppearance?) -> Color {
        switch feedbackAppearance {
        case .error:
            return .ds.text.danger.quiet
        case .none:
            return .ds.text.neutral.quiet
        }
    }
}

struct TextFieldTextualFeedback_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldTextualFeedback("Some additional information.")
    }
}
