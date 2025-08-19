import SwiftUI

struct GroupedTextFieldPreview: View {
  @State private var login = "_"
  @State private var firstname = ""
  @State private var lastname = ""
  @State private var email = ""
  @State private var website = "_"

  private let suggestedEmailAddresses = [
    "_",
    "_",
    "_",
  ]

  var body: some View {
    List {
      DS.TextField("Firstname", placeholder: "Enter your firstname", text: $firstname)
        .fieldLabelHiddenOnFocus()

      DS.TextField("Lastname", text: $lastname)

      DS.TextField("Disabled", text: .constant("Disabled value"))
        .disabled(true)

      DS.TextField(
        "Email", text: $email,
        actions: {
          FieldAction.Menu("Suggestions", image: .ds.action.more.outlined) {
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
      .textInputAutocapitalization(.never)
      .keyboardType(.URL)
      .autocorrectionDisabled()

      DS.TextField(
        "Website with Error Feedback",
        placeholder: "Your favorite website",
        text: $website
      )
      .textFieldColorHighlightingMode(.url)
      .textInputAutocapitalization(.never)
      .keyboardType(.URL)
      .autocorrectionDisabled()
      .style(.error)

      DS.TextField("OTP Code", text: .constant("48712"))
        .fieldEditionDisabled()

      DS.TextField(
        "Soft disabled edition mode",
        text: .constant("This is a really long value that should spawn on multiple lines.")
      )
      .fieldEditionDisabled(appearance: .discrete)

      DS.TextField("Edition Disabled w/o value", placeholder: nil, text: .constant(""))
        .fieldEditionDisabled()
    }
    .listStyle(.ds.insetGrouped)
  }
}

struct TextFieldPreview: View {
  @State private var login = "_"
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
    "_",
  ]

  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        DS.TextField(
          "Email Address", text: $login,
          actions: {
            FieldAction.ClearContent(text: $login)
          }
        )
        .textInputAutocapitalization(.never)
        .textContentType(.emailAddress)
        .autocorrectionDisabled()

        DS.TextField(
          "Email Address", text: $login,
          actions: {
            FieldAction.ClearContent(text: $login)
          },
          feedback: {
            FieldTextualFeedback("Some additional information")
          }
        )
        .style(.error)

        DS.TextField("Simple", text: $firstname)

        DS.TextField("Read-only", text: .constant("static information"))
          .fieldEditionDisabled()

        DS.TextField("Label", text: .constant("This is my content"))
          .disabled(true)
      }
      .padding()
      .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
    }
  }
}

#Preview("Standalone") {
  TextFieldPreview()
    .ignoresSafeArea([.keyboard], edges: .bottom)
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
}

#Preview("Grouped") {
  GroupedTextFieldPreview()
    .ignoresSafeArea([.keyboard], edges: .bottom)
    .background(Color.ds.background.alternate, ignoresSafeAreaEdges: .all)
}
