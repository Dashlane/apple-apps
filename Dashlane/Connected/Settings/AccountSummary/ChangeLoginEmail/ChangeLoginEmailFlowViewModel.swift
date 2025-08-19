import Combine
import CoreLocalization
import CoreSession
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import LoginKit
import StateMachine
import UserTrackingFoundation
import VaultKit

@MainActor
public class ChangeLoginEmailFlowViewModel: StateMachineBasedObservableObject,
  SessionServicesInjecting
{
  enum Step: Equatable {
    case newEmail
    case verificationCode
    case success(newSession: Session)
    case failure
  }

  @Published
  public var stateMachine: ChangeLoginEmailStateMachine

  @Published
  public var isPerformingEvent: Bool = false

  @Published
  var steps: [Step]

  @Published
  var errorMessage: String?

  let session: Session
  let currentLoginEmail: String
  let dismissPublisher = PassthroughSubject<Void, Never>()
  let lifeCycleHandler: SessionLifeCycleHandler?
  let activityReporter: ActivityReporterProtocol

  init(
    session: Session,
    container: SessionsContainerProtocol,
    userDeviceAPI: UserDeviceAPIClient,
    syncService: SyncServiceProtocol,
    keychainService: AuthenticationKeychainServiceProtocol,
    logger: Logger,
    lifeCycleHandler: SessionLifeCycleHandler?,
    activityReporter: ActivityReporterProtocol
  ) {
    let servicesStateHandling = ChangeEmailBackgroundServicesStateHandling(syncService: syncService)
    self.stateMachine = ChangeLoginEmailStateMachine(
      session: session,
      apiClient: userDeviceAPI,
      container: container,
      keychainService: keychainService,
      backgroundServicesStateHandling: servicesStateHandling,
      logger: logger[.session])
    self.session = session
    self.lifeCycleHandler = lifeCycleHandler
    self.activityReporter = activityReporter
    self.currentLoginEmail = session.login.email
    self.steps = [.newEmail]
  }

  public func update(
    for event: ChangeLoginEmailStateMachine.Event,
    from oldState: ChangeLoginEmailStateMachine.State,
    to newState: ChangeLoginEmailStateMachine.State
  ) async {
    switch (newState, event) {
    case (.pendingNewLogin, .reset):
      if steps.last == .failure {
        steps.append(.newEmail)
      } else {
        errorMessage = nil
        _ = self.steps.popLast()
      }
    case (let .pendingNewLogin(_, _, error), _):
      if let error {
        errorMessage = CoreL10n.errorMessage(for: error)
        activityReporter.reportErrorEncountered(error: error)
      }
    case (let .pendingConfirmation(_, _, error), _):
      if steps.last != .verificationCode {
        steps.append(.verificationCode)
      }

      if let error {
        errorMessage = CoreL10n.errorMessage(for: error)
        activityReporter.reportErrorEncountered(error: error)
      }
    case (let .completed(newSession), _):
      steps.append(.success(newSession: newSession))
      activityReporter.report(
        UserEvent.UserChangeLoginEmail(changeLoginEmailFlowStep: .successfulEmailChange))
    case (.failed, _):
      steps.append(.failure)
      activityReporter.report(
        UserEvent.UserChangeLoginEmail(changeLoginEmailFlowStep: .error, errorName: .generic))
    case (.canceled, _):
      dismissPublisher.send()
    }
  }

  func requestLognEmailChange(newLoginEmail: String) async {
    await perform(.requestChange(newLogin: Login(newLoginEmail)))
  }

  func validateVerificationCode(verificationCode: String) async {
    await perform(.confirm(token: verificationCode))
  }

  func resendVerificationCode() async {
    await perform(.resendToken)
  }

  func cancel() async {
    await perform(.cancel)
  }

  func reset() async {
    await perform(.reset)
  }

  func relogin(newSession: Session) {
    lifeCycleHandler?.logoutAndPerform(
      action: .startNewSession(newSession, reason: .loginEmailChanged))
  }
}

struct ChangeEmailBackgroundServicesStateHandling: BackgroundServicesStateHandling {
  let syncService: SyncServiceProtocol

  public func deactivate() async throws {
    try await syncService.syncAndDisable()
  }

  public func activate() async throws {
    syncService.enableSync(triggeredBy: .login)
  }
}

extension CoreL10n {
  public static func errorMessage(for error: ChangeLoginEmailStateMachine.ChangeLoginEmailError)
    -> String
  {
    switch error {
    case .invalidEmail:
      return CoreL10n.ChangeLoginEmail.invalidEmail
    case .existingEmail:
      return CoreL10n.ChangeLoginEmail.unavailableEmail
    case .invalidToken:
      return CoreL10n.ChangeLoginEmail.invalidToken
    }
  }
}

extension ActivityReporterProtocol {
  fileprivate func reportErrorEncountered(error: ChangeLoginEmailStateMachine.ChangeLoginEmailError)
  {
    switch error {
    case .invalidEmail:
      report(
        UserEvent.UserChangeLoginEmail(changeLoginEmailFlowStep: .error, errorName: .invalidEmail))
    case .existingEmail:
      report(
        UserEvent.UserChangeLoginEmail(changeLoginEmailFlowStep: .error, errorName: .existingEmail))
    case .invalidToken:
      report(
        UserEvent.UserChangeLoginEmail(changeLoginEmailFlowStep: .error, errorName: .wrongToken))
    }
  }
}

extension ChangeLoginEmailFlowViewModel {
  static var mock: ChangeLoginEmailFlowViewModel {
    ChangeLoginEmailFlowViewModel(
      session: .mock,
      container: FakeSessionsContainer(),
      userDeviceAPI: .fake,
      syncService: .mock(),
      keychainService: .mock,
      logger: .mock,
      lifeCycleHandler: nil,
      activityReporter: .mock)
  }
}
