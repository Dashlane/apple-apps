import LogFoundation
import StateMachine
import SwiftTreats

public struct PasswordlessAccountCreationStateMachine: StateMachine {

  public enum State: Hashable, Sendable {
    case initial
    case pinSetup
    case biometrySetup(Biometry)
    case waitingForUserConsent(email: String, password: String)
    case accountCreated(Session, LocalConfiguration)
    case accountCreationFailed(StateMachineError)
    case cancelled
  }

  public enum Event {
    case startPinSetup
    case pinSetupCompleted(pin: String)
    case biometrySetupCompleted(isEnabled: Bool)
    case userConsentCompleted(hasUserAcceptedEmailMarketing: Bool)
    case back
    case cancel
  }

  public private(set) var state: State = .initial

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
    self.configuration = configuration
    self.accountCreationService = accountCreationService
    self.biometry = biometry
    self.logger = logger
  }

  mutating public func transition(with event: Event) async throws {
    logger.info("Received event \(event)")
    switch event {
    case .startPinSetup:
      switch state {
      case .initial:
        state = .pinSetup

      case .pinSetup, .biometrySetup, .waitingForUserConsent, .accountCreated,
        .accountCreationFailed, .cancelled:
        let errorMessage: LogMessage = "Unexpected \(event) event for the state \(state)"
        logger.fatal(errorMessage)
        throw InvalidTransitionError<Self>(event: event, state: state)
      }

    case .pinSetupCompleted(let pin):
      switch state {
      case .pinSetup:
        self.configuration.local.pincode = pin
        if let biometry {
          state = .biometrySetup(biometry)
        } else {
          state = .waitingForUserConsent(
            email: configuration.email.address, password: configuration.password)
        }

      case .initial, .biometrySetup, .waitingForUserConsent, .accountCreated,
        .accountCreationFailed, .cancelled:
        let errorMessage: LogMessage = "Unexpected \(event) event for the state \(state)"
        logger.fatal(errorMessage)
        throw InvalidTransitionError<Self>(event: event, state: state)
      }

    case .biometrySetupCompleted(let isEnabled):
      switch state {
      case .biometrySetup:
        self.configuration.local.isBiometricAuthenticationEnabled = isEnabled
        state = .waitingForUserConsent(
          email: configuration.email.address, password: configuration.password)

      case .initial, .pinSetup, .waitingForUserConsent, .accountCreated, .accountCreationFailed,
        .cancelled:
        let errorMessage: LogMessage = "Unexpected \(event) event for the state \(state)"
        logger.fatal(errorMessage)
        throw InvalidTransitionError<Self>(event: event, state: state)
      }

    case .userConsentCompleted(let hasUserAcceptedEmailMarketing):
      switch state {
      case .waitingForUserConsent:
        self.configuration.hasUserAcceptedEmailMarketing = hasUserAcceptedEmailMarketing
        do {
          let session = try await accountCreationService.createAccount(using: configuration)
          state = .accountCreated(session, configuration.local)
        } catch {
          state = .accountCreationFailed(StateMachineError(underlyingError: error))
        }

      case .initial, .pinSetup, .biometrySetup, .accountCreated, .accountCreationFailed, .cancelled:
        let errorMessage: LogMessage = "Unexpected \(event) event for the state \(state)"
        logger.fatal(errorMessage)
        throw InvalidTransitionError<Self>(event: event, state: state)
      }

    case .back:
      switch state {
      case .initial:
        state = .cancelled

      case .pinSetup:
        state = .initial

      case .biometrySetup:
        self.configuration.local.pincode = nil
        self.state = .pinSetup

      case .waitingForUserConsent:
        self.configuration.local.pincode = nil
        if let biometry {
          self.state = .biometrySetup(biometry)
        } else {
          self.state = .pinSetup
        }

      case .accountCreated, .accountCreationFailed, .cancelled:
        let errorMessage: LogMessage = "Unexpected \(event) event for the state \(state)"
        logger.fatal(errorMessage)
        throw InvalidTransitionError<Self>(event: event, state: state)
      }

    case .cancel:
      switch state {
      case .initial, .pinSetup, .biometrySetup, .waitingForUserConsent:
        state = .cancelled

      case .cancelled, .accountCreated, .accountCreationFailed:
        let errorMessage: LogMessage = "Unexpected \(event) event for the state \(state)"
        logger.fatal(errorMessage)
        throw InvalidTransitionError<Self>(event: event, state: state)
      }
    }
    let state = state
    logger.info("Transition to state: \(state)")
  }
}
