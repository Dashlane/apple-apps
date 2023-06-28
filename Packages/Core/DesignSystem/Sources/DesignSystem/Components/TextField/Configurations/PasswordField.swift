import SwiftUI

public struct PasswordField<ActionsContent: View, FeedbackView: View>: View {
    private let label: String
    private let placeholder: String?
    private let text: Binding<String>
    private let actionsContent: ActionsContent
    private let feedbackView: FeedbackView

    @State private var displayRevealAction: Bool
    @State private var revealSecureValue = false

                                                                                                public init(
        _ label: String,
        placeholder: String? = nil,
        text: Binding<String>,
        @ViewBuilder actions: () -> ActionsContent = { EmptyView() },
        @ViewBuilder feedback: () -> FeedbackView = { EmptyView() }
    ) {
        self.label = label
        self.placeholder = placeholder
        self.text = text
        self.actionsContent = actions()
        self.feedbackView = feedback()
        self._displayRevealAction = .init(initialValue: !text.wrappedValue.isEmpty)
    }

    public var body: some View {
        DS.TextField(label, placeholder: placeholder, text: text) {
                        if displayRevealAction {
                TextFieldAction.RevealSecureContent(reveal: $revealSecureValue)
            }
            actionsContent
        } feedback: {
            feedbackView
        }
        .secureInput()
        .textFieldRevealSecureValue(revealSecureValue)
        .onChange(of: text.wrappedValue) { text in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                displayRevealAction = !text.isEmpty
            }
        }
        .textFieldColorHighlightingMode(.password)
    }
}

struct PasswordField_Previews: PreviewProvider {
    struct Preview: View {
        @State private var displayConditionalAction = false
        @State private var password = ""
        @State private var masterPassword = ""

        var body: some View {
            VStack(spacing: 20) {
                PasswordField(
                    "Password",
                    text: $password,
                    actions: {
                    if displayConditionalAction {
                        TextFieldAction.Button("Surprise", image: Image.ds.tip.filled) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                password = ""
                            }
                        }
                    }
                    TextFieldAction.Button("Notification", image: Image.ds.notification.filled) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            password = ""
                        }
                    }
                                                            TextFieldAction.Button("Bye Bye", image: Image.ds.itemColor.filled) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            password = ""
                        }
                    }
                }, feedback: {
                    TextFieldTextualFeedback("Important information here.")
                })

                PasswordField(
                    "Master Password",
                    placeholder: "Enter your master password",
                    text: $masterPassword,
                    feedback: {
                        TextFieldPasswordStrengthFeedback(strength: .good)
                    }
                )
            }
            .padding(.horizontal)
            .backgroundColorIgnoringSafeArea(.ds.background.alternate)
            .onChange(of: password) { value in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
                    displayConditionalAction = value == "_"
                }
            }
        }
    }
    static var previews: some View {
        Preview()
    }
}
