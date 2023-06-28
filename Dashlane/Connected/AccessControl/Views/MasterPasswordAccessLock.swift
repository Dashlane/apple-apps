import SwiftUI
import UIDelight
import UIComponents
import CoreLocalization
import DesignSystem

struct MasterPasswordAccessLockView: View {
    let title: String
    let validation: (String) -> Void
    let dismiss: () -> Void

    @State
    var enteredPassword: String = ""

    @FocusState
    var isTextFieldFocused: Bool

    @State
    var shouldReveal: Bool = true

    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.headline)
                .padding()
            DS.PasswordField(
                CoreLocalization.L10n.Core.kwEnterYourMasterPassword,
                text: $enteredPassword
            )
                .focused($isTextFieldFocused)
                .onSubmit(validate)
                .submitLabel(.go)
                .textInputAutocapitalization(.never)
                .textContentType(.oneTimeCode) 
                .autocorrectionDisabled()
                .padding()
            Divider()
            Button(CoreLocalization.L10n.Core.cancel, action: self.dismiss)
                .buttonStyle(AlertButtonStyle())

        }
        .modifier(AlertStyle())
        .onAppear {
            isTextFieldFocused = true
        }
    }

    func validate() {
        self.validation(enteredPassword)
    }
}

struct MasterPasswordAccessLockView_Previews: PreviewProvider {
    static var previews: some View {
        MasterPasswordAccessLockView(title: "Title",
                                     validation: { _ in },
                                     dismiss: { })
    }
}
