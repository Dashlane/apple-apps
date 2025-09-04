import CorePasswords
import CoreSession
import CoreTypes
import LoginKit
import StateMachine
import SwiftUI
import UserTrackingFoundation

@MainActor
class AccountCreationFlowViewModel: ObservableObject, AccountCreationFlowDependenciesInjecting,
  StateMachineBasedObservableObject
{

  var isPerformingEvent: Bool = false

  enum Step {
    case email
    case create(AccountCreationType)
  }

  enum AccountCreationType {
    case masterPassword(email: Email, isB2BAccount: Bool)
    case sso(email: Email, SSOLoginInfo)
  }

  enum CompletionResult {
    case finished(SessionServicesContainer)
    case cancel
  }

  @Published
  var steps: [Step]

  let completion: @MainActor (CompletionResult) -> Void
  let evaluator: PasswordEvaluatorProtocol
  let activityReporter: ActivityReporterProtocol
  let sessionServicesLoader: SessionServicesLoader
  var stateMachine: AccountCreationStateMachine
  let emailViewModelFactory: AccountEmailViewModel.Factory
  let regularAccountCreationFlowViewModelFactory: RegularAccountCreationFlowViewModel.Factory
  let ssoAccountCreationFlowViewModelFactory: SSOAccountCreationFlowViewModel.Factory

  private var savedMasterPassword: String?

  init(
    initialStep: AccountCreationFlowViewModel.Step,
    stateMachine: AccountCreationStateMachine,
    evaluator: PasswordEvaluatorProtocol,
    activityReporter: ActivityReporterProtocol,
    sessionServicesLoader: SessionServicesLoader,
    emailViewModelFactory: AccountEmailViewModel.Factory,
    regularAccountCreationFlowViewModelFactory: RegularAccountCreationFlowViewModel.Factory,
    ssoAccountCreationFlowViewModelFactory: SSOAccountCreationFlowViewModel.Factory,
    completion: @escaping @MainActor (AccountCreationFlowViewModel.CompletionResult) -> Void
  ) {
    self.stateMachine = stateMachine
    self.evaluator = evaluator
    self.activityReporter = activityReporter
    self.sessionServicesLoader = sessionServicesLoader
    self.emailViewModelFactory = emailViewModelFactory
    self.regularAccountCreationFlowViewModelFactory = regularAccountCreationFlowViewModelFactory
    self.ssoAccountCreationFlowViewModelFactory = ssoAccountCreationFlowViewModelFactory
    self.completion = completion
    self.steps = [initialStep]
  }

  func update(
    for event: AccountCreationStateMachine.Event, from oldState: AccountCreationStateMachine.State,
    to newState: AccountCreationStateMachine.State
  ) async {
    switch (newState, event) {
    case (.waitingForEmailInput, .start):
      steps.append(.email)
    case (.waitingForEmailInput, .cancel):
      self.steps.removeLast()
    case (let .regularAccountCreation(_, email, isB2BAccount), _):
      self.steps.append(.create(.masterPassword(email: email, isB2BAccount: isB2BAccount)))
    case (let .ssoAccountCreation(_, email, info), _):
      self.steps.append(.create(.sso(email: email, info)))
    case (.cancelled, _):
      self.completion(.cancel)
    default: break
    }
  }

  func makeEmailViewModel() -> AccountEmailViewModel {
    emailViewModelFactory.make { [weak self] result in
      guard let self = self else {
        return
      }
      Task {
        switch result {
        case let .next(email, isB2BAccount):
          await self.perform(.userDidEnterEmail(.regular(email, isB2B: isB2BAccount)))
        case let .sso(email, info):
          await self.perform(.userDidEnterEmail(.sso(email, info)))
        case .cancel:
          await self.perform(.cancel)
        }
      }
    }
  }

  func makeRegularAccountCreationFlowViewModel(email: Email, isB2BAccount: Bool)
    -> RegularAccountCreationFlowViewModel
  {
    regularAccountCreationFlowViewModelFactory.make(
      sessionservicesLoader: sessionServicesLoader,
      stateMachine: stateMachine.makeRegularAccountcreationFlowStateMachine(
        login: Login(email.address), isB2B: isB2BAccount)
    ) { [weak self] result in
      guard let self else {
        return
      }

      switch result {
      case let .finished(sessionServices):
        self.completion(.finished(sessionServices))
      case .cancel:
        Task {
          await self.perform(.cancel)
        }
      }
    }
  }

  func makeSSOAccountCreationFlowViewModel(email: Email, info: SSOLoginInfo)
    -> SSOAccountCreationFlowViewModel
  {
    ssoAccountCreationFlowViewModelFactory.make(
      email: email,
      stateMachine: stateMachine.makeSSOAccountCreationFlowStateMachine(
        login: Login(email.address), info: info)
    ) { [weak self] result in
      guard let self else {
        return
      }

      Task {
        switch result {
        case let .accountCreated(session):
          do {
            let sessionServices = try await self.sessionServicesLoader.load(
              for: session, context: .accountCreation)
            self.completion(.finished(sessionServices))
          } catch {
            self.completion(.cancel)
          }
        case .cancel:
          Task {
            await self.perform(.cancel)
          }
        }
      }

    }
  }
}
