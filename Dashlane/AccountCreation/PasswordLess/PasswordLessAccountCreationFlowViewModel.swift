import CoreSession
import CoreTypes
import Foundation
import LoginKit
import StateMachine
import SwiftTreats

@MainActor
class PasswordLessAccountCreationFlowViewModel: StateMachineBasedObservableObject,
  AccountCreationFlowDependenciesInjecting
{
  var isPerformingEvent: Bool = false

  enum Step {
    case intro
    case pinCode
    case biometry(biometry: Biometry)
    case userConsent(email: String, password: String)
    case complete(SessionServicesContainer)
  }

  enum CompletionResult {
    case finished(SessionServicesContainer)
    case cancel
  }

  @Published
  var steps: [Step] = [.intro]

  @Published
  var error: Error?

  let userConsentViewModelFactory: UserConsentViewModel.Factory
  let fastLocalSetupViewModelFactory: FastLocalSetupInAccountCreationViewModel.Factory

  let completion: @MainActor (PasswordLessAccountCreationFlowViewModel.CompletionResult) -> Void
  let sessionServicesLoader: SessionServicesLoader
  var stateMachine: PasswordlessAccountCreationStateMachine

  init(
    sessionServicesLoader: SessionServicesLoader,
    stateMachine: PasswordlessAccountCreationStateMachine,
    userConsentViewModelFactory: UserConsentViewModel.Factory,
    fastLocalSetupViewModelFactory: FastLocalSetupInAccountCreationViewModel.Factory,
    completion: @escaping @MainActor (PasswordLessAccountCreationFlowViewModel.CompletionResult) ->
      Void
  ) {
    self.stateMachine = stateMachine
    self.completion = completion
    self.sessionServicesLoader = sessionServicesLoader
    self.userConsentViewModelFactory = userConsentViewModelFactory
    self.fastLocalSetupViewModelFactory = fastLocalSetupViewModelFactory
  }

  func update(
    for event: PasswordlessAccountCreationStateMachine.Event,
    from oldState: PasswordlessAccountCreationStateMachine.State,
    to newState: PasswordlessAccountCreationStateMachine.State
  ) async {
    func popLastStepOrPush(_ step: Step) {
      if case .back = event {
        _ = steps.popLast()
      } else {
        steps.append(step)
      }
    }

    switch newState {
    case .initial:
      steps = [.intro]
    case let .biometrySetup(biometry):
      popLastStepOrPush(.biometry(biometry: biometry))
    case .pinSetup:
      popLastStepOrPush(.pinCode)
    case let .waitingForUserConsent(email, password):
      popLastStepOrPush(.userConsent(email: email, password: password))
    case let .accountCreated(session, localConfig):
      await self.load(session, with: localConfig)
    case let .accountCreationFailed(error):
      self.error = error.underlyingError
    case .cancelled:
      self.completion(.cancel)
    }
  }

  func makePinViewModel() -> PinCodeSelectionViewModel {
    PinCodeSelectionViewModel { pin in
      let event: Machine.Event = pin.map { .pinSetupCompleted(pin: $0) } ?? .back
      Task {
        await self.perform(event)
      }
    }
  }

  func completeBiometrySetup(_ result: BiometricQuickSetupView.CompletionResult) {
    Task {
      await self.perform(.biometrySetupCompleted(isEnabled: result == .useBiometry))
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

        case .back:
          await self.perform(.back)
        }
      }
    }
  }

  func startCreation() {
    Task {
      await perform(.startPinSetup)
    }
  }

  private func load(_ session: Session, with localConfig: LocalConfiguration) async {
    do {
      let sessionServices = try await sessionServicesLoader.load(
        for: session, context: .accountCreation)
      sessionServices.activityReporter.logAccountCreationSuccessful()
      sessionServices.apply(localConfig)
      self.steps.append(.complete(sessionServices))
    } catch {
      self.error = error
    }
  }

  func finish(with sessionServices: SessionServicesContainer) {
    self.completion(.finished(sessionServices))
  }

  func cancel() {
    Task {
      await self.perform(.cancel)
    }
  }
}
