import DesignSystem
import SwiftUI

struct MyView: View {
  @State private var firstname = ""
  @State private var website = ""
  @State private var isFirstNameInvalid = false
  @State private var password = ""

  var body: some View {
    List {
      DS.TextField(
        "Firstname",
        placeholder: "Enter your firstname",
        text: $firstname,
        actions: {
          FieldAction.ClearContent(text: $firstname)
          FieldAction.Menu(
            "More", image: .ds.action.more.outlined
          ) {
            Button("Action One") {}
            Button("Action Two") {}
          }
        },
        feedback: {
          if isFirstNameInvalid {
            FieldTextualFeedback("This firstname is invalid.")
          }
        }
      )
      .onSubmit {
        isFirstNameInvalid = true
      }

      DS.TextField(
        "Website",
        text: $website
      )
      .textColorHighlightingMode(.url)
      .textInputDisableLabelPersistency()
      .editionDisabled()

      DS.PasswordField(
        "Password",
        text: $password
      )
      .onRevealSecureValue {
      }
    }
    .fieldAppearance(.grouped)
    .style(isFirstNameInvalid ? .error : nil)
  }
}
