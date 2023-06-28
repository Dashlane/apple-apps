import SwiftUI
import DesignSystem

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
                    TextFieldAction.ClearContent(text: $firstname)
                    TextFieldAction.Menu(
                        "More", image: .ds.action.more.outlined
                    ) {
                        Button("Action One") {}
                        Button("Action Two") {}
                    }
                },
                feedback: {
                    if isFirstNameInvalid {
                        TextFieldTextualFeedback("This firstname is invalid.")
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
            .textFieldDisableLabelPersistency()

            DS.PasswordField(
                "Password",
                text: $password
            )
            .onRevealSecureValue {
                            }
        }
        .textFieldAppearance(.grouped)
        .textFieldFeedbackAppearance(isFirstNameInvalid ? .error : nil)
    }
}
