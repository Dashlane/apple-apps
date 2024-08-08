import DesignSystem
import SwiftUI

struct MyView: View {
  @State private var masterPassword = ""

  var body: some View {
    DS.PasswordField(
      "Master Password",
      placeholder: "Enter your master password",
      text: $masterPassword,
      actions: {
        FieldAction.Button("Do something", image: .ds.action.copy.outlined) {
        }
      },
      feedback: {
        FieldTextualFeedback("An important information.")
      }
    )
  }
}
