import CorePasswords
import CoreSession
import CoreTypes
import LoginKit
import StateMachine
import SwiftUI
import UserTrackingFoundation

@MainActor
class RegularAccountCreationFlowViewModel: StateMachineBasedObservableObject,
  AccountCreationFlowDependenciesInjecting
{
  var isPerformingEvent: Bool = false

  enum Step {
    case masterPassword(email: Email, isB2BAccount: Bool)
    case create(AccountCreationConfiguration)
  }

  enum CompletionResult {
    case finished(SessionServicesContainer)
    case cancel
  }

  @Published
  var steps: [Step] = []

  let completion: @MainActor (CompletionResult) -> Void
  let evaluator: PasswordEvaluatorProtocol
  let sessionservicesLoader: SessionServicesLoader
  let activityReporter: ActivityReporterProtocol
  let masterPasswordAccountCreationModelFactory: MasterPasswordAccountCreationFlowViewModel.Factory
  let passwordLessAccountCreationModelFactory: PasswordLessAccountCreationFlowViewModel.Factory

  private var savedMasterPassword: String?

  var stateMachine: RegularAccountCreationStateMachine
  var sessionServices: SessionServicesContainer?

  init(
    sessionservicesLoader: SessionServicesLoader,
    stateMachine: RegularAccountCreationStateMachine,
    evaluator: PasswordEvaluatorProtocol,
    activityReporter: ActivityReporterProtocol,
    masterPasswordAccountCreationModelFactory: MasterPasswordAccountCreationFlowViewModel.Factory,
    passwordLessAccountCreationModelFactory: PasswordLessAccountCreationFlowViewModel.Factory,
    completion: @escaping @MainActor (RegularAccountCreationFlowViewModel.CompletionResult) -> Void
  ) {
    self.sessionservicesLoader = sessionservicesLoader
    self.evaluator = evaluator
    self.activityReporter = activityReporter
    self.stateMachine = stateMachine
    self.masterPasswordAccountCreationModelFactory = masterPasswordAccountCreationModelFactory
    self.passwordLessAccountCreationModelFactory = passwordLessAccountCreationModelFactory
    self.completion = completion
    Task {
      await self.perform(.start)
    }
  }

  func update(
    for event: CoreSession.RegularAccountCreationStateMachine.Event,
    from oldState: CoreSession.RegularAccountCreationStateMachine.State,
    to newState: CoreSession.RegularAccountCreationStateMachine.State
  ) async {
    switch newState {
    case .initial: break
    case let .waitingForUserInput(email, isB2BAccount):
      self.steps = [.masterPassword(email: email, isB2BAccount: isB2BAccount)]
    case let .passwordAccountCreation(_, config):
      self.steps.append(.create(config))
    case let .passwordlessAccountCreation(_, config):
      self.steps.append(.create(config))
    case .accountCreated:
      guard let sessionServices = sessionServices else {
        return
      }
      self.completion(.finished(sessionServices))
    case .cancelled:
      self.completion(.cancel)
    }
  }

  func makeNewPasswordModel(email: Email) -> NewMasterPasswordViewModel {
    NewMasterPasswordViewModel(
      mode: .accountCreation,
      masterPassword: savedMasterPassword,
      evaluator: evaluator,
      activityReporter: activityReporter
    ) { [weak self] result in
      guard let self = self else {
        return
      }

      Task {
        switch result {
        case let .next(masterPassword: masterPassword):
          self.savedMasterPassword = masterPassword
          await self.perform(.userEnteredPassword(password: masterPassword))
        case let .back(masterPassword: masterPassword):
          self.savedMasterPassword = masterPassword
          await self.perform(.cancel)
        }
      }

    }
  }

  func startPasswordLess(email: Email) async {
    await self.perform(.createPasswordlessAccount)
  }

  func makeMasterPasswordAccountCreationFlow(configuration: AccountCreationConfiguration)
    -> MasterPasswordAccountCreationFlowViewModel
  {
    let stateMachine = stateMachine.makeMasterPasswordAccountCreationFlowStateMachine(
      configuration: configuration)
    return masterPasswordAccountCreationModelFactory.make(
      sessionservicesLoader: sessionservicesLoader, stateMachine: stateMachine
    ) { [weak self] result in
      guard let self = self else {
        return
      }
      Task {
        switch result {
        case let .finished(sessionServices):
          self.sessionServices = sessionServices
          await self.perform(.accountCreated)
        case .cancel:
          await self.perform(.cancel)
        }
      }
    }
  }

  func makePasswordLessAccountCreationFlow(configuration: AccountCreationConfiguration)
    -> PasswordLessAccountCreationFlowViewModel
  {
    let stateMachine = stateMachine.makePasswordlessAccountCreationFlowStateMachine(
      configuration: configuration)
    return passwordLessAccountCreationModelFactory.make(
      sessionServicesLoader: sessionservicesLoader, stateMachine: stateMachine
    ) { [weak self] result in
      guard let self = self else {
        return
      }
      Task {
        switch result {
        case let .finished(sessionServices):
          self.sessionServices = sessionServices
          await self.perform(.accountCreated)
        case .cancel:
          await self.perform(.cancel)
        }
      }
    }
  }
}
