import CorePasswords
import CorePersonalData
import CoreSession
import DashlaneAPI
import Foundation
import LoginKit
import UserTrackingFoundation

enum AccountRecoveryActivationContext {
  case onboarding
  case settings
}

@MainActor
class AccountRecoveryActivationEmbeddedFlowModel: ObservableObject, SessionServicesInjecting {
  enum Step {
    case intro
    case previewKey(AccountRecoveryKey)
    case confirmKey(AccountRecoveryKey)
  }

  @Published
  var steps: [Step]

  private let accountRecoveryKeyService: AccountRecoveryKeySetupService
  let authenticationMethod: AuthenticationMethod
  let context: AccountRecoveryActivationContext
  let activityReporter: ActivityReporterProtocol
  let completion: @MainActor () -> Void

  init(
    accountRecoveryKeyService: AccountRecoveryKeySetupService,
    session: Session,
    context: AccountRecoveryActivationContext,
    activityReporter: ActivityReporterProtocol,
    completion: @escaping @MainActor () -> Void
  ) {
    self.accountRecoveryKeyService = accountRecoveryKeyService
    self.authenticationMethod = session.authenticationMethod
    self.context = context
    self.completion = completion
    self.activityReporter = activityReporter
    steps = [.intro]
  }

  func gererateAccountRecoveryKey() {
    let accountRecoveryKey = accountRecoveryKeyService.generateAccountRecoveryKey()
    self.steps.append(.previewKey(accountRecoveryKey))
  }

  func makeAccountRecoveryConfirmationViewModel(
    with recoveryKey: AccountRecoveryKey, completion: @escaping () -> Void
  ) -> AccountRecoveryConfirmationViewModel {
    AccountRecoveryConfirmationViewModel(
      recoveryKey: recoveryKey, accountRecoveryKeyService: accountRecoveryKeyService,
      activityReporter: activityReporter, completion: completion)
  }
}

extension AccountRecoveryActivationEmbeddedFlowModel {
  static var mock: AccountRecoveryActivationEmbeddedFlowModel {
    AccountRecoveryActivationEmbeddedFlowModel(
      accountRecoveryKeyService: .mock, session: .mock, context: .onboarding,
      activityReporter: .mock
    ) {

    }
  }
}
