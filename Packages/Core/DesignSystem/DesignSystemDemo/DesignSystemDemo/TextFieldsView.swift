import DesignSystem
import SwiftUI
import UIKit

struct TextFieldsView: View {
  enum ViewConfiguration: String, CaseIterable {
    case passwords
    case feedbacks
    case passwordStrengths
    case actions
    case appearancesLight
    case appearancesDark
    case smallestDynamicTypeClass
    case largestDynamicTypeClass
  }

  var viewConfiguration: ViewConfiguration? {
    guard let configuration = ProcessInfo.processInfo.environment["textFieldsConfiguration"]
    else { return nil }
    return ViewConfiguration(rawValue: configuration)
  }

  enum FocusedField {
    case login
    case masterPassword
    case typeAnything
  }

  @FocusState private var focusedField: FocusedField?
  @State private var login = "_"
  @State private var masterPassword = ""
  @State private var text = ""

  var body: some View {
    switch viewConfiguration {
    case .passwords:
      passwords
    case .feedbacks:
      feedbacks
    case .passwordStrengths:
      passwordStrengths
    case .actions:
      actions
    case .appearancesLight:
      passwords
        .colorScheme(.light)
    case .appearancesDark:
      passwords
        .colorScheme(.dark)
    case .smallestDynamicTypeClass:
      passwords
        .environment(\.sizeCategory, .extraSmall)
    case .largestDynamicTypeClass:
      passwords
        .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
    case .none:
      EmptyView()
    }
  }

  private var passwords: some View {
    ScrollView {
      VStack(spacing: 20) {
        DS.PasswordField("Password 1", text: $masterPassword)
        DS.PasswordField("Password 2", text: .constant("Pa$$w0rd"))
        DS.PasswordField("Password 3", text: .constant("Pa$$w0rd"))
          .style(.error)
        DS.PasswordField(
          "Password 4", text: .constant("Pa$$w0rd"),
          feedback: {
            FieldTextualFeedback("The content of the feedback.")
          })
        DS.PasswordField(
          "Password 5", text: .constant("Pa$$w0rd"),
          feedback: {
            FieldTextualFeedback("The content of the feedback.")
          }
        )
        .editionDisabled()
        DS.PasswordField(
          "Password 6", text: .constant("Pa$$w0rd"),
          feedback: {
            FieldTextualFeedback("The content of the feedback.")
          }
        )
        .style(.error)
      }
      .padding()
    }
    .frame(maxHeight: .infinity, alignment: .top)
    .backgroundColorIgnoringSafeArea(Color(uiColor: .secondarySystemBackground))
  }

  private var passwordStrengths: some View {
    VStack(spacing: 20) {
      DS.TextField(
        "Weakest", text: .constant(""),
        feedback: {
          TextInputPasswordStrengthFeedback(strength: .weakest)
        })

      DS.TextField(
        "Weak", text: .constant(""),
        feedback: {
          TextInputPasswordStrengthFeedback(strength: .weak)
        })

      DS.TextField(
        "Acceptable", text: .constant(""),
        feedback: {
          TextInputPasswordStrengthFeedback(strength: .acceptable)
        })

      DS.TextField(
        "Good", text: .constant(""),
        feedback: {
          TextInputPasswordStrengthFeedback(strength: .good)
        })

      DS.TextField(
        "Strong", text: .constant(""),
        feedback: {
          TextInputPasswordStrengthFeedback(strength: .strong)
        })

      DS.TextField(
        "Strong – Colorful", text: .constant(""),
        feedback: {
          TextInputPasswordStrengthFeedback(strength: .strong, colorful: true)
        })
    }
    .frame(maxHeight: .infinity, alignment: .top)
    .padding()
    .backgroundColorIgnoringSafeArea(Color(uiColor: .secondarySystemBackground))
  }

  private var feedbacks: some View {
    VStack(spacing: 20) {
      DS.TextField(
        "Textual",
        text: .constant(""),
        feedback: {
          FieldTextualFeedback("Content of the textual feedback.")
        }
      )

      DS.TextField(
        "Textual multilines", text: .constant(""),
        feedback: {
          FieldTextualFeedback("This is\na multiline textual feedback.")
        })

      DS.TextField(
        "Textual w/ error appearance", text: .constant(""),
        feedback: {
          FieldTextualFeedback("Content of the textual feedback.")
        }
      )
      .style(.error)

      DS.TextField(
        "Password Strength",
        text: .constant(""),
        feedback: {
          TextInputPasswordStrengthFeedback(strength: .good)
        }
      )
    }
    .frame(maxHeight: .infinity, alignment: .top)
    .padding()
    .backgroundColorIgnoringSafeArea(Color(uiColor: .secondarySystemBackground))
  }

  private var actions: some View {
    VStack(spacing: 20) {
      DS.TextField("No Actions", text: .constant(""))

      DS.TextField(
        "Built-in Clear Content", text: .constant("Test"),
        actions: {
          DS.FieldAction.ClearContent(text: .constant("Test"))
        })

      DS.PasswordField("Built-in Reveal", text: .constant("Hello"))
        .fieldLabelPersistencyDisabled()

      DS.TextField(
        "1 Action", text: .constant("Static value"),
        actions: {
          DS.FieldAction.CopyContent {}
        }
      )
      .fieldLabelPersistencyDisabled()
      .editionDisabled()

      DS.TextField(
        "2 Actions", text: .constant(""),
        actions: {
          DS.FieldAction.CopyContent {}
          DS.FieldAction.Button(
            "Password Generator",
            image: .ds.feature.passwordGenerator.outlined,
            action: {}
          )
        })

      DS.TextField(
        "3 Actions", text: .constant(""),
        actions: {
          DS.FieldAction.CopyContent {}
          DS.FieldAction.Button(
            "Password Generator",
            image: .ds.feature.passwordGenerator.outlined,
            action: {}
          )
          DS.FieldAction.Button(
            "Open",
            image: .ds.action.openExternalLink.outlined,
            action: {}
          )
        })

      DS.TextField(
        "3 Actions + error appearance", text: .constant(""),
        actions: {
          DS.FieldAction.CopyContent {}
          DS.FieldAction.Button(
            "Password Generator",
            image: .ds.feature.passwordGenerator.outlined,
            action: {}
          )
          DS.FieldAction.Button(
            "Open",
            image: .ds.action.openExternalLink.outlined,
            action: {}
          )
        }
      )
      .style(.error)

      DS.TextField(
        "Auto More Menu", text: .constant(""),
        actions: {
          DS.FieldAction.CopyContent {}
          DS.FieldAction.Button(
            "Password Generator",
            image: .ds.feature.passwordGenerator.outlined,
            action: {}
          )
          DS.FieldAction.Button(
            "Open External Link",
            image: .ds.action.openExternalLink.outlined,
            action: {}
          )
          DS.FieldAction.Button(
            "Refresh",
            image: .ds.action.refresh.outlined,
            action: {}
          )
        })

      DS.TextField(
        "Manual More Menu", text: .constant(""),
        actions: {
          DS.FieldAction.Menu("More Menu", image: .ds.action.more.outlined) {
            Button(
              action: {},
              label: {
                Label(
                  title: { Text("Copy") },
                  icon: { Image.ds.action.copy.outlined }
                )
              }
            )
            Button(
              action: {},
              label: {
                Label(
                  title: { Text("Password Generator") },
                  icon: { Image.ds.feature.passwordGenerator.outlined }
                )
              }
            )
            Button(
              action: {},
              label: {
                Label(
                  title: { Text("Open External Link") },
                  icon: { Image.ds.action.openExternalLink.outlined }
                )
              }
            )
          }
        })
    }
    .frame(maxHeight: .infinity, alignment: .top)
    .padding()
    .backgroundColorIgnoringSafeArea(Color(uiColor: .secondarySystemBackground))
  }
}

struct TextInputView_Previews: PreviewProvider {
  static var previews: some View {
    TextFieldsView()
  }
}
