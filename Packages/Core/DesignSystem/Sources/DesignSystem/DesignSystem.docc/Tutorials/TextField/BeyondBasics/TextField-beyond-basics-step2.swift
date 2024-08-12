import DesignSystem
import SwiftUI

struct MyView: View {
  @State private var firstname = ""
  @State private var isFirstNameInvalid = false

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
    }
    .fieldAppearance(.grouped)
    .style(isFirstNameInvalid ? .error : nil)
  }
}
