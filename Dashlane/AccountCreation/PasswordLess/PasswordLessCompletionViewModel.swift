import DashTypes
import Foundation
import SwiftTreats

@MainActor
class PasswordLessCompletionViewModel: ObservableObject, SessionServicesInjecting {

  let accountRecoveryActivationFlowFactory: AccountRecoveryActivationEmbeddedFlowModel.Factory
  let completion: () -> Void

  init(
    accountRecoveryActivationFlowFactory: AccountRecoveryActivationEmbeddedFlowModel.Factory,
    completion: @escaping () -> Void
  ) {
    self.accountRecoveryActivationFlowFactory = accountRecoveryActivationFlowFactory
    self.completion = completion
  }

  func makeAccountRecoveryActivationFlowModel() -> AccountRecoveryActivationEmbeddedFlowModel {
    accountRecoveryActivationFlowFactory.make(context: .onboarding) { [weak self] in
      self?.completion()
    }
  }
}
