import CoreTypes
import DashlaneAPI
import LogFoundation
import StateMachine

public struct ChangeLoginEmailStateMachine: StateMachine {
  public enum State: Sendable, Hashable {
    case pendingNewLogin(
      isInvalidLogin: Bool, isLoginAlreadyUsed: Bool, error: ChangeLoginEmailError? = nil)
    case pendingConfirmation(
      newLogin: Login, hasSubmittedWrongToken: Bool, error: ChangeLoginEmailError? = nil)
    case completed(newSession: Session)
    case failed(StateMachineError)
    case canceled
  }

  public enum Event: Sendable {
    case requestChange(newLogin: Login)
    case resendToken
    case confirm(token: String)
    case reset
    case cancel
  }

  public enum ChangeLoginEmailError: Error {
    case invalidEmail
    case existingEmail
    case invalidToken
  }

  public var state: State = .pendingNewLogin(isInvalidLogin: false, isLoginAlreadyUsed: false)
  private let session: Session
  private let apiClient: UserDeviceAPIClient
  private let container: SessionsContainerProtocol
  private let backgroundServicesStateHandling: BackgroundServicesStateHandling
  private let logger: Logger
  private let keychainService: AuthenticationKeychainServiceProtocol

  public init(
    session: Session,
    apiClient: UserDeviceAPIClient,
    container: SessionsContainerProtocol,
    keychainService: AuthenticationKeychainServiceProtocol,
    backgroundServicesStateHandling: BackgroundServicesStateHandling,
    logger: Logger
  ) {
    self.session = session
    self.apiClient = apiClient
    self.container = container
    self.backgroundServicesStateHandling = backgroundServicesStateHandling
    self.logger = logger
    self.keychainService = keychainService
  }

  public mutating func transition(with event: Event) async throws {
    logger.info("Received event \(event)")
    switch (state, event) {
    case (.pendingNewLogin, .requestChange(let newLogin)):
      do {
        guard Email(newLogin.email).isValid else {
          logger.error("Invalid login")
          state = .pendingNewLogin(
            isInvalidLogin: true, isLoginAlreadyUsed: false, error: .invalidEmail)
          let state = state
          logger.info("Transition to state: \(state)")
          return
        }

        try await apiClient.user.requestLoginChange(newLogin: newLogin.email)
        state = .pendingConfirmation(newLogin: newLogin, hasSubmittedWrongToken: false)
      } catch let error as APIError where error.hasUserCode(.loginUnavailable) {
        state = .pendingNewLogin(
          isInvalidLogin: false, isLoginAlreadyUsed: true, error: .existingEmail)
        logger.error("Login Already Used")
      } catch {
        logger.error("Couldn't request login email change", error: error)
        state = .failed(.init(underlyingError: error))
      }
    case (.pendingConfirmation(let newLogin, _, _), .resendToken):
      do {
        try await apiClient.user.sendLoginChangeToken()
        state = .pendingConfirmation(newLogin: newLogin, hasSubmittedWrongToken: false)
      } catch {
        logger.error("Couldn't send login token again", error: error)
      }
    case (.pendingConfirmation(let newLogin, _, _), .confirm(let token)):
      do {
        try await backgroundServicesStateHandling.deactivate()

        try await apiClient.user.completeLoginChange(validationToken: token)
        let newSession = try container.update(session, to: newLogin)
        keychainService.update(session, to: newLogin)
        state = .completed(newSession: newSession)
      } catch let error as APIError where error.hasUserCode(.tokenValidationFailed) {
        try await backgroundServicesStateHandling.activate()
        state = .pendingConfirmation(
          newLogin: newLogin, hasSubmittedWrongToken: true, error: .invalidToken)
      } catch {
        try await backgroundServicesStateHandling.activate()
        logger.error("Couldn't confirm login email change", error: error)
        state = .failed(.init(underlyingError: error))
      }
    case (_, .reset):
      state = .pendingNewLogin(isInvalidLogin: false, isLoginAlreadyUsed: false)
    case (_, .cancel):
      state = .canceled
    default:
      let errorMessage: LogMessage = "Unexpected \(event) event for the state \(state)"
      logger.fatal(errorMessage)
      throw InvalidTransitionError<Self>(event: event, state: state)
    }
    let state = state
    logger.info("Transition to state: \(state)")
  }
}

extension AuthenticationKeychainServiceProtocol {
  func update(_ session: Session, to newLogin: Login) {
    let masterKeyStatus = masterKeyStatus(for: session.login)
    if case let .available(accessMode: accessMode) = masterKeyStatus {
      try? saveMasterKey(
        session.authenticationMethod.sessionKey,
        for: newLogin,
        accessMode: accessMode)
    }
    if let pin = try? pincode(for: session.login) {
      try? setPincode(pin, for: newLogin)
    }

    try? removeMasterKey(for: session.login)
    try? setPincode(nil, for: session.login)
  }
}

extension ChangeLoginEmailStateMachine {
  public static var mock: ChangeLoginEmailStateMachine {
    ChangeLoginEmailStateMachine(
      session: .mock,
      apiClient: .fake,
      container: FakeSessionsContainer(),
      keychainService: .mock,
      backgroundServicesStateHandling: .mock(),
      logger: .mock
    )
  }
}
