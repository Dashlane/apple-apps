import SwiftUI

struct TextFieldFeedbackContainer<Content: View>: View {
    private let content: Content
    @ScaledMetric private var topPadding = 4

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, topPadding)
    }
}

struct TextFieldFeedbackContainer_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TextFieldFeedbackContainer {
                TextFieldTextualFeedback("Some additional information.")
            }
            .background(.red.opacity(0.2))

            TextFieldFeedbackContainer {
                TextFieldPasswordStrengthFeedback(strength: .weak)
            }
            .background(.red.opacity(0.2))
        }
        .padding(.horizontal, 20)
    }
}
