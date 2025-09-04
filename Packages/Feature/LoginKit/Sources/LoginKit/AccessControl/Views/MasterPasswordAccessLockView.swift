import CoreLocalization
import DesignSystem
import DesignSystemExtra
import SwiftUI
import UIComponents
import UIDelight
import UserTrackingFoundation

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
    NativeAlert(spacing: 0) {
      Text(model.reason.promptMessage)
        .font(.headline)
        .padding()
      DS.PasswordField(
        CoreL10n.kwEnterYourMasterPassword,
        text: $model.enteredPassword
      )
      .focused($isTextFieldFocused)
      .onSubmit(model.validate)
      .submitLabel(.go)
      .textInputAutocapitalization(.never)
      .textContentType(.oneTimeCode)
      .autocorrectionDisabled()
      .padding()
    } buttons: {
      Button(CoreL10n.cancel, role: .cancel, action: self.model.cancel)
    }
    .onAppear {
      isTextFieldFocused = true

      report?(UserEvent.AskAuthentication(mode: .masterPassword, reason: model.reason.logReason))
    }
    .alert(CoreL10n.kwWrongMasterPassword, isPresented: $model.showWrongPassword) {
      Button(CoreL10n.kwButtonOk, role: .cancel) {
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
