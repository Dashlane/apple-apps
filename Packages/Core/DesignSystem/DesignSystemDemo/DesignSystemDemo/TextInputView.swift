import SwiftUI
import DesignSystem

struct TextInputView: View {
    enum ViewConfiguration: String, CaseIterable {
        case standardConfigurations
        case appearancesLight
        case appearancesDark
        case smallestDynamicTypeClass
        case largestDynamicTypeClass
    }
    
    var viewConfiguration: ViewConfiguration? {
        guard let configuration = ProcessInfo.processInfo.environment["textInputsConfiguration"]
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
        case .standardConfigurations:
            textFields
        case .appearancesLight:
            textFields
                .colorScheme(.light)
        case .appearancesDark:
            textFields
                .colorScheme(.dark)
        case .smallestDynamicTypeClass:
            textFields
                .environment(\.sizeCategory, .extraSmall)
        case .largestDynamicTypeClass:
            textFields
                .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
        case .none:
            EmptyView()
        }
    }
    
    private var textFields: some View {
        ScrollView {
            VStack(spacing: 20) {
                TextInput("Email Address", text: $login)
                    .focused($focusedField, equals: .login)
                    .textInputAutocapitalization(.never)
                    .textContentType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputLabel("Login")
                TextInput("Master Password Empty", text: $masterPassword) {
                    Button("Forgot?") {}
                }
                .focused($focusedField, equals: .masterPassword)
                .textInputIsSecure(true)
                TextInput("Master Password Filled", text: .constant("Master Password")) {
                    Button("Forgot?") {}
                }
                .textInputIsSecure(true)
                TextInput("Type Anything Quiet!", text: $text)
                    .focused($focusedField, equals: .typeAnything)
                    .style(intensity: .quiet)
                    .textInputLabel("Quiet")
                TextInput("Type Anything Supershy!", text: $text)
                    .focused($focusedField, equals: .typeAnything)
                    .style(intensity: .supershy)
                    .textInputLabel("Supershy")
            }
            .padding()
        }
        .backgroundColorIgnoringSafeArea(Color(uiColor: .secondarySystemBackground))
    }
}

struct TextInputView_Previews: PreviewProvider {
    static var previews: some View {
        TextInputView()
    }
}

