import CoreLocalization
import CoreSession
import CoreTypes
import Foundation
import LogFoundation
import Logger
import LoginKit
import StateMachine
import UserTrackingFoundation

@MainActor
public class SSOAccountCreationFlowViewModel: AccountCreationFlowDependenciesInjecting,
  StateMachineBasedObservableObject
{

  public var isPerformingEvent: Bool = false
  public var stateMachine: SSOAccountCreationStateMachine

  enum Step: Equatable {
    case initial
    case authenticate(serviceProviderUrl: URL, isNitroProvider: Bool)
    case userConsent(ssoToken: String, serviceProviderKey: String)
  }

  @Published
  var steps: [Step] = [.initial]

  public enum CompletionResult {
    case accountCreated(Session)
    case cancel
  }

  @Loggable
  enum ErrorItem {
    case validityError
    case genericError(String)
  }

  var error: Error? {
    didSet {
      guard let error else {
        return
      }
      if case AccountCreationError.expiredVersion = error {
        errorItem = .validityError
      } else {
        errorItem = .genericError(CoreL10n.errorMessage(for: error))
      }
    }
  }

  @Published
  var errorItem: ErrorItem?

  let email: CoreTypes.Email
  private let activityReporter: ActivityReporterProtocol
  private let completion: (CompletionResult) -> Void
  private let logger: Logger
  private let userCountryProvider: UserCountryProvider
  private let ssoViewModelFactory: SSOViewModel.Factory

  init(
    email: CoreTypes.Email,
    stateMachine: SSOAccountCreationStateMachine,
    userCountryProvider: UserCountryProvider,
    logger: Logger,
    activityReporter: ActivityReporterProtocol,
    ssoViewModelFactory: SSOViewModel.Factory,
    completion: @escaping (SSOAccountCreationFlowViewModel.CompletionResult) -> Void
  ) {
    self.email = email
    self.stateMachine = stateMachine
    self.completion = completion
    self.userCountryProvider = userCountryProvider
    self.activityReporter = activityReporter
    self.logger = logger[.accountCreation]
    self.ssoViewModelFactory = ssoViewModelFactory
    Task {
      await perform(.askUserAuthentication)
    }
  }

  public func update(
    for event: Machine.Event, from oldState: Machine.State, to newState: Machine.State
  ) async {
    switch newState {
    case .initial: break
    case let .waitingForUserAuthentication(serviceProviderUrl, isNitroProvider):
      activityReporter.logAskAuthentication()
      steps = [
        .authenticate(serviceProviderUrl: serviceProviderUrl, isNitroProvider: isNitroProvider)
      ]
    case let .waitingForUserConsent(ssoToken, serviceProviderKey):
      steps.append(.userConsent(ssoToken: ssoToken, serviceProviderKey: serviceProviderKey))
    case .cancelled:
      self.completion(.cancel)
    case let .userAuthenticationFailed(error):
      _ = self.steps.popLast()
      self.error = error.underlyingError
    case let .accountCreated(session):
      activityReporter.logSuccessfulLogin()
      self.completion(.accountCreated(session))
    case let .accountCreationFailed(error):
      self.error = error.underlyingError
      self.completion(.cancel)
    }
  }

  func handleSSOLoginResult(_ result: Result<SSOCompletion, Error>) {
    Task {
      switch result {
      case let .success(type):
        switch type {
        case let .completed(callbackInfos):
          await self.perform(
            .userAuthenticationDidSucceed(
              ssoToken: callbackInfos.ssoToken,
              serviceProviderKey: callbackInfos.serviceProviderKey))
        case .cancel:
          await self.perform(.cancel)
        }
      case let .failure(error):
        await self.perform(.userAuthenticationFailed(StateMachineError(underlyingError: error)))
      }
    }
  }

  func cancel() async {
    await perform(.askUserAuthentication)
  }
}

extension ActivityReporterProtocol {
  fileprivate func logAskAuthentication() {
    report(UserEvent.AskAuthentication(mode: .sso, reason: .login))
  }

  fileprivate func logSuccessfulLogin() {
    report(
      UserEvent.Login(
        isFirstLogin: true,
        mode: .sso,
        status: .success,
        verificationMode: Definition.VerificationMode.none))
  }
}

extension SSOAccountCreationFlowViewModel {
  func makeSSOViewModel(serviceProviderUrl: URL, isNitroProvider: Bool) -> SSOViewModel {
    ssoViewModelFactory.make(
      ssoAuthenticationInfo: SSOAuthenticationInfo(
        login: Login(email.address), serviceProviderUrl: serviceProviderUrl,
        isNitroProvider: isNitroProvider, migration: nil)
    ) { result in
      self.handleSSOLoginResult(result)
    }
  }

  func makeUserConsentViewModel(ssoToken: String, serviceProviderKey: String)
    -> SSOUserConsentViewModel
  {
    SSOUserConsentViewModel(userCountryProvider: userCountryProvider) { result in
      Task {
        switch result {
        case let .finished(hasUserAcceptedTermsAndConditions, hasUserAcceptedEmailMarketing):
          await self.perform(
            .createAccount(
              SSOAccountCreationConfig(
                ssoToken: ssoToken, serviceProviderKey: serviceProviderKey,
                hasUserAcceptedTermsAndConditions: hasUserAcceptedTermsAndConditions,
                hasUserAcceptedEmailMarketing: hasUserAcceptedEmailMarketing)))
        case .cancel:
          await self.perform(.cancel)
        }
      }
    }
  }
}

extension SSOViewModel: AccountCreationFlowDependenciesInjecting {}

extension ConfidentialSSOViewModel: AccountCreationFlowDependenciesInjecting {}

extension SelfHostedSSOViewModel: AccountCreationFlowDependenciesInjecting {}
