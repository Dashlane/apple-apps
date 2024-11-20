import CoreLocalization
import CoreUserTracking
import DesignSystem
import MacrosKit
import SwiftUI
import UIComponents
import UIDelight

@ViewInit
struct MasterPasswordAccessLockView: View {
  @StateObject
  var model: MasterPasswordAccessLockViewModel

  @FocusState
  var isTextFieldFocused: Bool

  @State
  var shouldReveal: Bool = true

  @Environment(\.report)
  var report

  var body: some View {
    VStack(spacing: 0) {
      Text(model.reason.promptMessage)
        .font(.headline)
        .padding()
      DS.PasswordField(
        CoreLocalization.L10n.Core.kwEnterYourMasterPassword,
        text: $model.enteredPassword
      )
      .focused($isTextFieldFocused)
      .onSubmit(model.validate)
      .submitLabel(.go)
      .textInputAutocapitalization(.never)
      .textContentType(.oneTimeCode)
      .autocorrectionDisabled()
      .padding()
      Divider()
      Button(CoreLocalization.L10n.Core.cancel, action: self.model.cancel)
        .buttonStyle(AlertButtonStyle())

    }
    .modifier(AlertStyle())
    .onAppear {
      isTextFieldFocused = true

      report?(UserEvent.AskAuthentication(mode: .masterPassword, reason: model.reason.logReason))
    }
    .alert(L10n.Localizable.kwWrongMasterPassword, isPresented: $model.showWrongPassword) {
      Button(CoreLocalization.L10n.Core.kwButtonOk, role: .cancel) {
        self.model.cancel()
      }
    }

  }
}

struct MasterPasswordAccessLockView_Previews: PreviewProvider {
  static var previews: some View {
    MasterPasswordAccessLockView(model: .mock())
  }
}
