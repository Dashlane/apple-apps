import CoreLocalization
import CoreSession
import CoreTypes
import Foundation
import SwiftUI
import UIComponents
import UIDelight

struct DeviceTransferRecoveryFlow: View {
  @StateObject
  var model: DeviceTransferRecoveryFlowModel

  var body: some View {
    StepBasedContentNavigationView(steps: $model.steps) { step in
      switch step {
      case .intro:
        DeviceTransferAccountRecoveryIntroView { result in
          Task {
            switch result {
            case .startRecovery:
              await model.startRecoveryFlow()
            case .startLostKey:
              await model.resetAccount()
            }
          }
        }
      case .accountReset:
        DeviceTransferAccountResetView()
      case .recoveryFlow:
        AccountRecoveryKeyLoginFlow(model: model.makeAccountRecoveryFlowModel())
          .navigationTitle(CoreL10n.accountRecoveryNavigationTitle)
      }
    }
  }
}

struct DeviceTransferRecoveryFlow_Preview: PreviewProvider {
  static var previews: some View {
    DeviceTransferRecoveryFlow(
      model: .init(
        login: Login("_"), stateMachine: .mock,
        recoveryKeyLoginFlowModelFactory: .init({ _, _, _ in
          .mock
        }), completion: { _ in }))
  }
}
