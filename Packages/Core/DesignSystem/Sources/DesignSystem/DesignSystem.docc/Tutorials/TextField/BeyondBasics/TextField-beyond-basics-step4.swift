import DesignSystem
import SwiftUI

struct MyView: View {
  @State private var firstname = ""
  @State private var website = ""
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

      DS.TextField(
        "Website",
        text: $website
      )
      .textFieldColorHighlightingMode(.url)
      .textInputDisableLabelPersistency()
    }
    .listStyle(.ds.insetGrouped)
    .style(isFirstNameInvalid ? .error : nil)
  }
}
