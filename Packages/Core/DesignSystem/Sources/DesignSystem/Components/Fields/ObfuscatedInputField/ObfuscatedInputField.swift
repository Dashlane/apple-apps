import SwiftUI

public struct ObfuscatedInputField<ActionsContent: View>: View {
  @Environment(\.defaultFieldActionsHidden) private var defaultFieldActionsHidden
  @Environment(\.fieldRequired) private var isRequired

  private let label: String
  private let placeholder: String?
  private let text: Binding<String>
  private let actionsContent: ActionsContent

  @State private var revealSecureValue: Bool

  public init(
    _ label: String,
    placeholder: String? = nil,
    text: Binding<String>,
    shouldReveal: Bool = false,
    @ViewBuilder actions: () -> ActionsContent = { EmptyView() }
  ) {
    self.label = label
    self.placeholder = placeholder
    self.text = text
    self.revealSecureValue = shouldReveal
    self.actionsContent = actions()
  }

  public var body: some View {
    TextInput(label, placeholder: placeholder, text: text.wrappedValue) {
      ObfuscatedFieldInputView(
        label: label, text: text, placeholder: placeholder, isPassword: false)
    } actions: {
      if !defaultFieldActionsHidden {
        FieldAction.RevealSecureContent(reveal: $revealSecureValue)
      }
      actionsContent
    } feedback: {
    }
    .defaultFieldActionsHidden(defaultFieldActionsHidden)
    .secureInput()
    .textFieldRevealSecureValue(revealSecureValue)
  }
}

private struct PreviewContent: View {
  @State private var creditCardNumber = "4533777784840101"

  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        VStack(spacing: 20) {
          ObfuscatedInputField(
            "Credit card number",
            placeholder: "Enter your credit card number",
            text: $creditCardNumber
          )
          .fieldRequired()

          ObfuscatedInputField(
            "Credit card number",
            placeholder: "Enter your credit card number",
            text: $creditCardNumber,
            shouldReveal: true
          ) {
            FieldAction.CopyContent {}
          }

          ObfuscatedInputField(
            "Credit card number",
            placeholder: "Enter your credit card number",
            text: $creditCardNumber
          )
          .defaultFieldActionsHidden()
          .fieldEditionDisabled()
        }
        .padding(.horizontal)
        .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
      }
    }
  }
}

#Preview {
  PreviewContent()
}
