import SwiftUI
import UIDelight
import UIComponents

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

            SecureField(L10n.Localizable.kwEnterYourMasterPassword, text: $enteredPassword)
                .focused($isTextFieldFocused)
                .onSubmit(validate)
                .submitLabel(.go)
                .textInputAutocapitalization(.never)
                .textContentType(.oneTimeCode) 
                .disableAutocorrection(true)
                .padding()
            Divider()
            Button(L10n.Localizable.cancel, action: self.dismiss)
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
