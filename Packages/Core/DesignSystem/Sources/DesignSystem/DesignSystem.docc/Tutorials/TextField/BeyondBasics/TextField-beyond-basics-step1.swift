import DesignSystem
import SwiftUI

struct MyView: View {
  @State private var firstname = ""

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
          FieldTextualFeedback("An important information.")
        }
      )
    }
    .fieldAppearance(.grouped)
  }
}
