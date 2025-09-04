import CoreSession
import Foundation
import LoginKit
import UserTrackingFoundation

@MainActor
class AccountRecoveryActivationFlowModel: ObservableObject, SessionServicesInjecting {
  let context: AccountRecoveryActivationContext
  let activityReporter: ActivityReporterProtocol
  let recoveryActivationViewModelFactory: AccountRecoveryActivationEmbeddedFlowModel.Factory

  var canSkip: Bool {
    context == .onboarding
  }

  init(
    context: AccountRecoveryActivationContext,
    activityReporter: ActivityReporterProtocol,
    recoveryActivationViewModelFactory: AccountRecoveryActivationEmbeddedFlowModel.Factory
  ) {
    self.context = context
    self.activityReporter = activityReporter
    self.recoveryActivationViewModelFactory = recoveryActivationViewModelFactory
    activityReporter.report(UserEvent.CreateAccountRecoveryKey(flowStep: .start))
  }

  func makeActivationViewModel(completion: @escaping @MainActor () -> Void)
    -> AccountRecoveryActivationEmbeddedFlowModel
  {
    recoveryActivationViewModelFactory.make(context: context, completion: completion)
  }

  func logCancel() {
    activityReporter.report(UserEvent.CreateAccountRecoveryKey(flowStep: .cancel))
  }
}

extension AccountRecoveryActivationFlowModel {
  static var mock: AccountRecoveryActivationFlowModel {
    AccountRecoveryActivationFlowModel(
      context: .onboarding, activityReporter: .mock,
      recoveryActivationViewModelFactory: .init { _, _ in .mock })
  }
}
