import CoreLocalization
import DesignSystemExtra
import SwiftUI
import UIComponents
import UIDelight
import UserTrackingFoundation

@ViewInit
struct PinCodeAccessLockView: View {
  @StateObject
  var model: PinCodeAccessLockViewModel

  @Environment(\.report)
  var report

  var body: some View {
    NativeAlert {
      VStack(spacing: 20) {
        Text(model.reason.promptMessage)
          .font(.headline)
        PinCodeView(
          pinCode: $model.enteredPincode,
          length: model.pinCodeLength,
          attempt: model.attempts,
          cancelAction: model.cancel
        ).padding()
      }
      #if !os(visionOS)
        .frame(height: UIScreen.main.bounds.height / 1.75)
      #endif
      .padding(.top, 20)
    }
    .alert(CoreL10n.kwWrongPinCodeMessage, isPresented: $model.showWrongPin) {
      Button(CoreL10n.kwButtonOk, role: .cancel) {
        self.model.cancel()
      }
    }
    .alert(CoreL10n.tooManyTokenAttempts, isPresented: $model.showTooManyAttempts) {
      Button(CoreL10n.kwButtonOk, role: .cancel) {
        self.model.cancel()
      }
    }
    .onAppear {
      report?(UserEvent.AskAuthentication(mode: .pin, reason: model.reason.logReason))
    }
  }
}

struct PinCodeAccessLockView_Previews: PreviewProvider {
  static var previews: some View {
    PinCodeAccessLockView(model: .mock())
  }
}
