import Foundation
import SwiftUI
import UIDelight

struct AccountRecoveryActivationEmbeddedFlow: View {
  @StateObject
  var model: AccountRecoveryActivationEmbeddedFlowModel
  let canSkip: Bool

  init(
    model: @escaping @autoclosure () -> AccountRecoveryActivationEmbeddedFlowModel, canSkip: Bool
  ) {
    self._model = .init(wrappedValue: model())
    self.canSkip = canSkip
  }

  var body: some View {
    StepBasedContentNavigationView(steps: $model.steps) { step in
      switch step {
      case .intro:
        AccountRecoveryActivationIntroView(
          authenticationMethod: model.authenticationMethod, canSkip: canSkip
        ) { result in
          switch result {
          case .generateKey:
            model.gererateAccountRecoveryKey()
          case .cancel:
            model.completion()
          }
        }
      case let .previewKey(recoveryKey):
        AccountRecoveryKeyPreviewView(recoveryKey: recoveryKey) {
          model.steps.append(.confirmKey(recoveryKey))
        }
      case let .confirmKey(recoveryKey):
        AccountRecoveryConfirmationView(
          model: model.makeAccountRecoveryConfirmationViewModel(with: recoveryKey) {
            model.completion()
          })
      }
    }
  }
}

struct AccountRecoveryActivationFlow_Previews: PreviewProvider {
  static var previews: some View {
    AccountRecoveryActivationEmbeddedFlow(model: .mock, canSkip: true)
    AccountRecoveryActivationEmbeddedFlow(model: .mock, canSkip: false)
  }
}
