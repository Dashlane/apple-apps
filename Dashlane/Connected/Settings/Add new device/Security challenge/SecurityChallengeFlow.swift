import Foundation
import SwiftUI
import UIDelight

struct SecurityChallengeFlow: View {

  @StateObject
  var model: SecurityChallengeFlowModel

  var body: some View {
    StepBasedNavigationView(steps: $model.steps) { step in
      switch step {
      case .pendingtransfer:
        DeviceTransferPendingRequestView(model: model.makeDeviceTransferPendingRequestViewModel())
      case let .passphrase(transferKeys):
        PassphraseInputView(model: model.makePassphraseInputViewModel(transferKeys: transferKeys))
      }
    }
  }
}
