import Combine
import CoreLocalization
import CoreUserTracking
import Foundation
import LoginKit
import MacrosKit
import SwiftUI
import UIDelight

@ViewInit
struct AccessControlView: View {
  @StateObject
  var model: AccessControlViewModel

  @Environment(\.report)
  var report

  var body: some View {
    content
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(backgroundView)
  }

  @ViewBuilder
  private var content: some View {
    switch model.mode {
    case let .masterPassword(masterPassword):
      MasterPasswordAccessLockView(
        model: model.makeMasterPasswordViewModel(masterPassword: masterPassword))

    case let .biometry(fallbackMode):
      Spacer()
        .onAppear {
          report?(UserEvent.AskAuthentication(mode: .biometric, reason: model.reason.logReason))

          model.validateBiometry(fallbackMode: fallbackMode)
        }

    case let .pin(lock):
      PinCodeAccessLockView(model: model.makePincodeViewModel(lock: lock))
    }
  }

  private var backgroundView: some View {
    Rectangle()
      .fill(.ultraThinMaterial)
      .edgesIgnoringSafeArea(.all)
      .frame(maxWidth: .infinity)
      .colorScheme(.dark)
  }
}

struct AccessControlView_Previews: PreviewProvider {
  static var previews: some View {
    let pinCodeLock = SecureLockMode.PinCodeLock(
      code: "1234",
      attempts: .mock,
      masterKey: .masterPassword("password"))
    AccessControlView(model: .mock(mode: .masterPassword("passwod")))
      .previewDisplayName("Master Password")
    AccessControlView(model: .mock(mode: .pin(pinCodeLock)))
      .previewDisplayName("Pincode")
  }

}
