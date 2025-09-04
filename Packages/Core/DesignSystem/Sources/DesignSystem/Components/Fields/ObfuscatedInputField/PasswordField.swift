import SwiftUI

public struct PasswordField<ActionsContent: View, FeedbackView: View>: View {
  @Environment(\.defaultFieldActionsHidden) private var defaultFieldActionsHidden

  private let label: String
  private let placeholder: String?
  private let text: Binding<String>
  private let actionsContent: ActionsContent
  private let feedbackView: FeedbackView

  @State private var revealSecureValue: Bool

  public init(
    _ label: String,
    placeholder: String? = nil,
    text: Binding<String>,
    shouldReveal: Bool = false,
    @ViewBuilder actions: () -> ActionsContent = { EmptyView() },
    @ViewBuilder feedback: () -> FeedbackView = { EmptyView() }
  ) {
    self.label = label
    self.placeholder = placeholder
    self.text = text
    self.revealSecureValue = shouldReveal
    self.actionsContent = actions()
    self.feedbackView = feedback()
  }

  public var body: some View {
    TextInput(label, placeholder: placeholder, text: text.wrappedValue) {
      ObfuscatedFieldInputView(label: label, text: text, placeholder: placeholder, isPassword: true)
    } actions: {
      if !defaultFieldActionsHidden {
        FieldAction.RevealSecureContent(reveal: $revealSecureValue)
      }
      actionsContent
    } feedback: {
      feedbackView
    }
    .defaultFieldActionsHidden(defaultFieldActionsHidden)
    .secureInput()
    .textFieldRevealSecureValue(revealSecureValue)
    .textFieldColorHighlightingMode(.password)
    .writingToolsDisabled()
  }
}

private struct PreviewContent: View {
  @State private var displayConditionalAction = false
  @State private var password = ""
  @State private var masterPassword = ""
  @State private var limitedRightsPassword = "A very secure password"

  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        PasswordField(
          "Password",
          text: $password,
          actions: {
            if displayConditionalAction {
              FieldAction.Button("Surprise", image: Image.ds.tip.filled) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                  password = ""
                }
              }
            }
            FieldAction.Button("Notification", image: Image.ds.notification.filled) {
              withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                password = ""
              }
            }
            FieldAction.Button("Bye Bye", image: Image.ds.itemColor.filled) {
              withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                password = ""
              }
            }
          },
          feedback: {
            FieldTextualFeedback("Important information here.")
          })

        PasswordField(
          "Master Password",
          placeholder: "Enter your master password",
          text: $masterPassword,
          feedback: {
            TextInputPasswordStrengthFeedback(strength: .good)
          }
        )

        PasswordField(
          "Master Password",
          placeholder: "Enter your master password",
          text: $masterPassword,
          actions: {
            FieldAction.Button("", image: .ds.action.copy.outlined, action: {})
          },
          feedback: {
            TextInputPasswordStrengthFeedback(strength: .good)
          }
        )
        .disabled(true)

        PasswordField(
          "Read-only",
          text: $limitedRightsPassword
        )
        .fieldEditionDisabled()

        PasswordField(
          "Password w/ limited rights",
          text: $limitedRightsPassword
        )
        .defaultFieldActionsHidden()
        .fieldEditionDisabled()
      }
      .padding(.horizontal)
      .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
      .onChange(of: password) { _, value in
        withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
          displayConditionalAction = value == "_"
        }
      }
    }
  }
}

#Preview {
  PreviewContent()
}
