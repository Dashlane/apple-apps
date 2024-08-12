import CoreLocalization
import CoreSession
import DashTypes
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
              model.startRecoveryFlow()
            case .startLostKey:
              model.resetAccount()
            }
          }
        }
      case .accountReset:
        DeviceTransferAccountResetView()
      case .recoveryFlow:
        AccountRecoveryKeyLoginFlow(model: model.makeAccountRecoveryFlowModel())
          .navigationTitle(L10n.Core.accountRecoveryNavigationTitle)
      }
    }
  }
}

struct DeviceTransferRecoveryFlow_Preview: PreviewProvider {
  static var previews: some View {
    DeviceTransferRecoveryFlow(
      model: .init(
        accountRecoveryInfo: AccountRecoveryInfo(
          login: Login("_"), isEnabled: false, accountType: .invisibleMasterPassword),
        deviceInfo: .mock,
        recoveryKeyLoginFlowModelFactory: .init({ _, _, _, _ in
          .mock
        }), completion: { _ in }))
  }
}
