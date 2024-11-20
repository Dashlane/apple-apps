import CoreLocalization
import CoreUserTracking
import LoginKit
import MacrosKit
import SwiftUI
import UIComponents

@ViewInit
struct PinCodeAccessLockView: View {
  @StateObject
  var model: PinCodeAccessLockViewModel

  @Environment(\.report)
  var report

  var body: some View {
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
    .frame(height: UIScreen.main.bounds.height / 1.75)
    .padding(.top, 20)
    .modifier(AlertStyle())
    .alert(L10n.Localizable.kwWrongPinCodeMessage, isPresented: $model.showWrongPin) {
      Button(CoreLocalization.L10n.Core.kwButtonOk, role: .cancel) {
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
