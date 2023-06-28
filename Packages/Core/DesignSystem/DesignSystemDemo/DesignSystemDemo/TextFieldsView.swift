import SwiftUI
import DesignSystem
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
                    .textFieldFeedbackAppearance(.error)
                DS.PasswordField("Password 4", text: .constant("Pa$$w0rd"), feedback: {
                    TextFieldTextualFeedback("The content of the feedback.")
                })
                DS.PasswordField("Password 5", text: .constant("Pa$$w0rd"), feedback: {
                    TextFieldTextualFeedback("The content of the feedback.")
                })
                .editionDisabled()
                DS.PasswordField("Password 6", text: .constant("Pa$$w0rd"), feedback: {
                    TextFieldTextualFeedback("The content of the feedback.")
                })
                .textFieldFeedbackAppearance(.error)
            }
            .padding()
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .backgroundColorIgnoringSafeArea(Color(uiColor: .secondarySystemBackground))
    }

    private var passwordStrengths: some View {
        VStack(spacing: 20) {
            DS.TextField("Weakest", text: .constant(""), feedback: {
                TextFieldPasswordStrengthFeedback(strength: .weakest)
            })

            DS.TextField("Weak", text: .constant(""), feedback: {
                TextFieldPasswordStrengthFeedback(strength: .weak)
            })

            DS.TextField("Acceptable", text: .constant(""), feedback: {
                TextFieldPasswordStrengthFeedback(strength: .acceptable)
            })

            DS.TextField("Good", text: .constant(""), feedback: {
                TextFieldPasswordStrengthFeedback(strength: .good)
            })

            DS.TextField("Strong", text: .constant(""), feedback: {
                TextFieldPasswordStrengthFeedback(strength: .strong)
            })

            DS.TextField("Strong – Colorful", text: .constant(""), feedback: {
                TextFieldPasswordStrengthFeedback(strength: .strong, colorful: true)
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
                    TextFieldTextualFeedback("Content of the textual feedback.")
                }
            )

            DS.TextField("Textual multilines", text: .constant(""), feedback: {
                TextFieldTextualFeedback("This is\na multiline textual feedback.")
            })

            DS.TextField("Textual w/ error appearance", text: .constant(""), feedback: {
                TextFieldTextualFeedback("Content of the textual feedback.")
            })
            .textFieldFeedbackAppearance(.error)

            DS.TextField(
                "Password Strength",
                text: .constant(""),
                feedback: {
                    TextFieldPasswordStrengthFeedback(strength: .good)
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

            DS.TextField("Built-in Clear Content", text: .constant("Test"), actions: {
                TextFieldClearContentButton(text: .constant("Test"))
            })

            DS.PasswordField("Built-in Reveal", text: .constant("Hello"))
                .textFieldDisableLabelPersistency()

            DS.TextField("1 Action", text: .constant("Static value"), actions: {
                TextFieldButtonAction("Copy", image: .ds.action.copy.outlined, action: {})
            })
            .textFieldDisableLabelPersistency()
            .editionDisabled()

            DS.TextField("2 Actions", text: .constant(""), actions: {
                TextFieldButtonAction("Copy", image: .ds.action.copy.outlined, action: {})
                TextFieldButtonAction(
                    "Password Generator",
                    image: .ds.feature.passwordGenerator.outlined,
                    action: {}
                )
            })

            DS.TextField("3 Actions", text: .constant(""), actions: {
                TextFieldButtonAction("Copy", image: .ds.action.copy.outlined, action: {})
                TextFieldButtonAction(
                    "Password Generator",
                    image: .ds.feature.passwordGenerator.outlined,
                    action: {}
                )
                TextFieldButtonAction(
                    "Open",
                    image: .ds.action.openExternalLink.outlined,
                    action: {}
                )
            })

            DS.TextField("3 Actions + error appearance", text: .constant(""), actions: {
                TextFieldButtonAction("Copy", image: .ds.action.copy.outlined, action: {})
                TextFieldButtonAction(
                    "Password Generator",
                    image: .ds.feature.passwordGenerator.outlined,
                    action: {}
                )
                TextFieldButtonAction(
                    "Open",
                    image: .ds.action.openExternalLink.outlined,
                    action: {}
                )
            })
            .textFieldFeedbackAppearance(.error)

            DS.TextField("Auto More Menu", text: .constant(""), actions: {
                TextFieldButtonAction("Copy", image: .ds.action.copy.outlined, action: {})
                TextFieldButtonAction(
                    "Password Generator",
                    image: .ds.feature.passwordGenerator.outlined,
                    action: {}
                )
                TextFieldButtonAction(
                    "Open External Link",
                    image: .ds.action.openExternalLink.outlined,
                    action: {}
                )
                TextFieldButtonAction("Refresh", image: .ds.action.refresh.outlined, action: {})
            })

            DS.TextField("Manual More Menu", text: .constant(""), actions: {
                TextFieldMenuAction("More Menu", image: .ds.action.more.outlined) {
                    Button(
                        action: {},
                        label: {
                            Label {
                                Text("Copy")
                            } icon: {
                                Image.ds.action.copy.outlined
                            }
                        }
                    )
                    Button(
                        action: {},
                        label: {
                            Label {
                                Text("Password Generator")
                            } icon: {
                                Image.ds.feature.passwordGenerator.outlined
                            }
                        }
                    )
                    Button(
                        action: {},
                        label: {
                            Label {
                                Text("Open External Link")
                            } icon: {
                                Image.ds.action.openExternalLink.outlined
                            }
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
