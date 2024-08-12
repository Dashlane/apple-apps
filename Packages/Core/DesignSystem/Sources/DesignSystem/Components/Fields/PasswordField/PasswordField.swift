import SwiftUI

public struct PasswordField<ActionsContent: View, FeedbackView: View>: View {
  @Environment(\.textInputBuiltInActionsRemoved) private var builtInActionsRemoved

  private let label: String
  private let placeholder: String?
  private let text: Binding<String>
  private let actionsContent: ActionsContent
  private let feedbackView: FeedbackView

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
  }

  public var body: some View {
    TextInput(label, placeholder: placeholder, text: text.wrappedValue) {
      PasswordFieldInputView(label: label, text: text, placeholder: placeholder)
    } actions: {
      if !builtInActionsRemoved {
        FieldAction.RevealSecureContent(reveal: $revealSecureValue)
      }
      actionsContent
    } feedback: {
      feedbackView
    }
    .actionlessField(builtInActionsRemoved)
    .secureInput()
    .textFieldRevealSecureValue(revealSecureValue)
    .textColorHighlightingMode(.password)
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
        .editionDisabled()

        PasswordField(
          "Password w/ limited rights",
          text: $limitedRightsPassword
        )
        .textInputRemoveBuiltInActions()
        .editionDisabled()
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
}

#Preview {
  PreviewContent()
}
