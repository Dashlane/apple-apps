import LogFoundation
import StateMachine
import SwiftTreats

public struct MasterPasswordAccountCreationStateMachine: StateMachine {

  @Loggable
  public enum State: Hashable, Sendable {
    case initial
    case fastLocalSetup(Biometry?)
    case waitingForUserConsent(email: String, password: String)
    case accountCreated(Session, LocalConfiguration)
    case accountCreationFailed(StateMachineError)
    case cancelled
  }

  @Loggable
  public enum Event {
    case start
    case fastLocalSetupCompleted(LocalConfiguration)
    case userConsentCompleted(hasUserAcceptedEmailMarketing: Bool)
    case cancel
  }

  public var state: State = .initial

  var configuration: AccountCreationConfiguration
  let accountCreationService: RegularAccountCreationServiceProtocol
  let biometry: Biometry?
  let logger: Logger

  init(
    configuration: AccountCreationConfiguration,
    biometry: Biometry?,
    accountCreationService: RegularAccountCreationServiceProtocol,
    logger: Logger
  ) {
    self.biometry = biometry
    self.configuration = configuration
    self.accountCreationService = accountCreationService
    self.logger = logger
  }

  mutating public func transition(with event: Event) async throws {
    logger.info("Received event \(event)")
    switch (state, event) {
    case (.initial, .start):
      if let biometry {
        state = .fastLocalSetup(biometry)
      } else if Device.is(.mac) {
        state = .fastLocalSetup(nil)
      } else {
        state = .waitingForUserConsent(
          email: configuration.email.address, password: configuration.password)
      }
    case (.fastLocalSetup, let .fastLocalSetupCompleted(localConfig)):
      self.configuration.local = localConfig
      state = .waitingForUserConsent(
        email: configuration.email.address, password: configuration.password)
    case (.waitingForUserConsent, let .userConsentCompleted(hasUserAcceptedEmailMarketing)):
      self.configuration.hasUserAcceptedEmailMarketing = hasUserAcceptedEmailMarketing
      do {
        let session = try await accountCreationService.createAccount(using: configuration)
        state = .accountCreated(session, configuration.local)
      } catch {
        state = .accountCreationFailed(StateMachineError(underlyingError: error))
      }
    case (_, .cancel):
      state = .cancelled
    default:
      let errorMessage: LogMessage = "Unexpected \(event) event for the state \(state)"
      logger.fatal(errorMessage)
      throw InvalidTransitionError<Self>(event: event, state: state)
    }
    let state = state
    logger.info("Transition to state: \(state)")
  }

}
