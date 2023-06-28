import SwiftUI

struct TextFieldPreview: View {
    @State private var login = "_"
    @State private var masterPassword = ""
    @State private var firstname = ""
    @State private var lastname = ""
    @State private var creditCardNumber = "4321-8765-9876-0001"
    @State private var email = ""
    @State private var website = "_"

    @State private var isMasterPasswordRevealed = false
    @State private var isCreditCardNumberRevealed = false

    private let suggestedEmailAddresses = [
        "_",
        "_",
        "_"
    ]

    var body: some View {
        VStack {
            VStack(spacing: 20) {
                DS.TextField("Email Address", text: $login, actions: {
                    TextFieldAction.ClearContent(text: $login)
                })
                    #if canImport(UIKit)
                    .textInputAutocapitalization(.never)
                    .textContentType(.emailAddress)
                    #endif
                    .autocorrectionDisabled()

                DS.TextField("Email Address", text: $login, feedback: {
                    TextFieldTextualFeedback("Some additional information")
                })
                .textFieldFeedbackAppearance(.error)

                DS.TextField("Master Password", text: $masterPassword) {
                    if !masterPassword.isEmpty {
                        TextFieldAction.RevealSecureContent(reveal: $isMasterPasswordRevealed)
                    }
                    TextFieldAction.Menu(
                        "More", image: .ds.action.more.outlined
                    ) {
                        Button("Action One") {}
                        Button("Action Two") {}
                    }
                } feedback: {
                    TextFieldFeedbackContainer {
                        TextFieldTextualFeedback("Some additional information.")
                    }
                }
                .secureInput()
                .textFieldRevealSecureValue(isMasterPasswordRevealed)
                .textFieldColorHighlightingMode(.password)

                DS.TextField("Read-only", text: .constant("static information"))
                    .editionDisabled()

                DS.TextField("Label", text: .constant("This is my content"))
                    .disabled(true)
            }
            .padding()
            .backgroundColorIgnoringSafeArea(.ds.background.alternate)
            .fixedSize(horizontal: false, vertical: true)

            List {
                DS.TextField("Firstname", placeholder: "Enter your firstname", text: $firstname)
                    .textFieldDisableLabelPersistency()

                DS.TextField("Lastname", text: $lastname)

                DS.TextField("Disabled", text: .constant("Disabled value"))
                    .disabled(true)

                DS.TextField("Credit Card Number", text: $creditCardNumber, actions: {
                    TextFieldAction.RevealSecureContent(reveal: $isCreditCardNumberRevealed)
                })
                .secureInput()
                .textFieldRevealSecureValue(isCreditCardNumberRevealed)

                DS.TextField("Email", text: $email, actions: {
                    TextFieldAction.Menu("Suggestions", image: .ds.action.more.outlined) {
                        ForEach(suggestedEmailAddresses, id: \.self) { suggestedEmail in
                            Button(suggestedEmail) {
                                email = suggestedEmail
                            }
                        }
                    }
                })

                DS.TextField(
                    "Website",
                    placeholder: "Your favorite website",
                    text: $website
                )
                .textFieldColorHighlightingMode(.url)
                #if canImport(UIKit)
                .textInputAutocapitalization(.never)
                .keyboardType(.URL)
                #endif
                .autocorrectionDisabled()

                DS.TextField(
                    "Website with Error Feedback",
                    placeholder: "Your favorite website",
                    text: $website
                )
                .textFieldColorHighlightingMode(.url)
                #if canImport(UIKit)
                .textInputAutocapitalization(.never)
                .keyboardType(.URL)
                #endif
                .autocorrectionDisabled()
                .textFieldFeedbackAppearance(.error)

                DS.TextField("OTP Code", text: .constant("48712"))
                    .editionDisabled()

                DS.TextField("Soft disabled edition mode", text: .constant("Value"))
                    .editionDisabled()
                    .textFieldDisabledEditionAppearance(.discrete)
            }
            .textFieldAppearance(.grouped)
            .scrollContentBackground(.hidden)
        }
    }
}

struct TextFieldPreview_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldPreview()
            .padding()
            .ignoresSafeArea([.keyboard], edges: .bottom)
            .backgroundColorIgnoringSafeArea(.ds.background.alternate)
    }
}
