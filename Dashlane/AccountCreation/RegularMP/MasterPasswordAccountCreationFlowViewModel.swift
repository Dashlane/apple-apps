import CoreSession
import CoreTypes
import Foundation
import LoginKit
import StateMachine
import SwiftTreats
import UserTrackingFoundation

@MainActor
class MasterPasswordAccountCreationFlowViewModel: StateMachineBasedObservableObject,
  AccountCreationFlowDependenciesInjecting
{
  var isPerformingEvent: Bool = false

  enum Step: Equatable {
    case fastLocalSetup(biometry: Biometry?)
    case userConsent(email: String, password: String)
  }

  enum CompletionResult {
    case finished(SessionServicesContainer)
    case cancel
  }

  @Published
  var steps: [Step] = [] {
    didSet {
      if steps.isEmpty {
        self.completion(.cancel)
      }
    }
  }

  @Published
  var error: Error?

  var stateMachine: MasterPasswordAccountCreationStateMachine
  let userConsentViewModelFactory: UserConsentViewModel.Factory
  let fastLocalSetupViewModelFactory: FastLocalSetupInAccountCreationViewModel.Factory
  let activityReporter: ActivityReporterProtocol
  let sessionServicesLoader: SessionServicesLoader
  let completion: @MainActor (MasterPasswordAccountCreationFlowViewModel.CompletionResult) -> Void

  init(
    sessionservicesLoader: SessionServicesLoader,
    stateMachine: MasterPasswordAccountCreationStateMachine,
    activityReporter: ActivityReporterProtocol,
    userConsentViewModelFactory: UserConsentViewModel.Factory,
    fastLocalSetupViewModelFactory: FastLocalSetupInAccountCreationViewModel.Factory,
    completion: @escaping @MainActor (MasterPasswordAccountCreationFlowViewModel.CompletionResult)
      -> Void
  ) {
    self.stateMachine = stateMachine
    self.sessionServicesLoader = sessionservicesLoader
    self.completion = completion
    self.activityReporter = activityReporter
    self.userConsentViewModelFactory = userConsentViewModelFactory
    self.fastLocalSetupViewModelFactory = fastLocalSetupViewModelFactory

    Task {
      await self.perform(.start)
    }
  }

  func update(
    for event: MasterPasswordAccountCreationStateMachine.Event,
    from oldState: MasterPasswordAccountCreationStateMachine.State,
    to newState: MasterPasswordAccountCreationStateMachine.State
  ) async {
    switch (newState, event) {
    case (.initial, _): break
    case (let .fastLocalSetup(biometry), _):
      self.steps = [.fastLocalSetup(biometry: biometry)]
    case (let .waitingForUserConsent(email, password), _):
      self.steps.append(.userConsent(email: email, password: password))
    case (.cancelled, _):
      guard case .waitingForUserConsent = oldState else {
        self.completion(.cancel)
        return
      }
      self.steps.removeLast()
    case (let .accountCreated(session, localConfig), _):
      await self.load(session, with: localConfig)
    case (let .accountCreationFailed(error), _):
      self.error = error.underlyingError
    }
  }

  func makeFastLocalSetup() -> FastLocalSetupInAccountCreationViewModel {
    return fastLocalSetupViewModelFactory.make { [weak self] completion in
      guard let self = self else {
        return
      }

      Task {
        switch completion {
        case let .next(localConfig):
          await self.perform(.fastLocalSetupCompleted(localConfig))
        case .back:
          await self.perform(.cancel)
        }
      }

    }
  }

  func makeUserContentViewModel() -> UserConsentViewModel {
    return userConsentViewModelFactory.make { [weak self] completion in
      guard let self = self else {
        return
      }
      Task {
        switch completion {
        case .next(_, let hasUserAcceptedEmailMarketing):
          await self.perform(
            .userConsentCompleted(hasUserAcceptedEmailMarketing: hasUserAcceptedEmailMarketing))

        case .back(_, let hasUserAcceptedEmailMarketing):
          await self.perform(.cancel)
        }
      }
    }
  }

  private func load(_ session: Session, with localConfig: LocalConfiguration) async {
    do {
      let sessionServices = try await sessionServicesLoader.load(
        for: session, context: .accountCreation)
      sessionServices.activityReporter.logAccountCreationSuccessful()
      sessionServices.apply(localConfig)
      self.completion(.finished(sessionServices))
    } catch {
      self.error = error
    }
  }

  func cancel() {
    self.completion(.cancel)
  }
}
