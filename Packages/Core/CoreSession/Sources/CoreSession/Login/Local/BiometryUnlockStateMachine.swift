import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import StateMachine
import UserTrackingFoundation

public struct BiometryUnlockStateMachine: StateMachine {

  public enum BiometryProgress: Hashable {
    case biometryInProgress
    case masterKeyValidationInProgress
  }

  public var state: State = .initial

  @Loggable
  public enum State: Hashable, Sendable {
    case initial
    case biometryFailed
    case biometryCancelled
    case masterKeyValidationSucceeded(Session)
    case masterKeyValidationFailed
    case cancelled
  }

  @Loggable
  public enum Event: Sendable {
    case startBiometryValidation
    case cancel
  }

  private let unlocker: UnlockSessionHandler
  private let keychainService: AuthenticationKeychainServiceProtocol
  private let login: Login
  private let logger: Logger
  private var loginSettings: LoginSettings
  private let context: LoginUnlockContext
  private let activityReporter: ActivityReporterProtocol

  public init(
    unlocker: UnlockSessionHandler,
    keychainService: AuthenticationKeychainServiceProtocol,
    login: Login,
    loginSettings: LoginSettings,
    logger: Logger,
    context: LoginUnlockContext,
    activityReporter: ActivityReporterProtocol
  ) {
    self.unlocker = unlocker
    self.keychainService = keychainService
    self.login = login
    self.logger = logger
    self.loginSettings = loginSettings
    self.context = context
    self.activityReporter = activityReporter
  }

  public mutating func transition(with event: Event) async throws {
    logger.info("Received event \(event)")
    switch (state, event) {
    case (.initial, .startBiometryValidation),
      (.biometryCancelled, .startBiometryValidation):
      self.activityReporter.logAskAuthentication(for: context)
      do {
        let masterKey = try self.keychainService.masterKey(for: self.login, using: nil)
        state = await validateMasterKey(masterKey)
      } catch {
        switch error {
        case KeychainError.decryptionFailure:
          logger.fatal("CryptoError: Keychain master key fetch failed for Biometry Unlock")
          state = .biometryFailed
        case KeychainError.userCanceledRequest:
          state = .biometryCancelled
        default:
          logger.info("Keychain master key fetch failed for Biometry Unlock")
          state = .biometryFailed
        }
      }
    case (_, .cancel):
      self.state = .cancelled
    default:
      let errorMessage: LogMessage = "Unexpected \(event) event for the state \(state)"
      logger.fatal(errorMessage)
      throw InvalidTransitionError<Self>(event: event, state: state)
    }
    let state = state
    logger.info("Transition to state: \(state)")
  }

  mutating func validateMasterKey(_ masterKey: CoreTypes.MasterKey) async -> State {
    do {
      switch masterKey {
      case .masterPassword(let masterPassword):
        let serverKey = self.keychainService.serverKey(for: self.login)
        let session = try await self.unlocker.validateMasterKey(
          .masterPassword(masterPassword, serverKey: serverKey))
        return .masterKeyValidationSucceeded(session)
      case .key(let key):
        let session = try await self.unlocker.validateMasterKey(.ssoKey(key))
        return .masterKeyValidationSucceeded(session)
      }
    } catch {
      try? self.keychainService.removeMasterKey(for: self.login)
      loginSettings.isBiometryEnabled = false
      self.activityReporter.logFailure(for: context)
      return .masterKeyValidationFailed
    }
  }
}

extension ActivityReporterProtocol {
  fileprivate func logAskAuthentication(for context: LoginUnlockContext) {
    report(UserEvent.AskAuthentication(mode: .biometric, reason: context.reason))
  }

  fileprivate func logFailure(for context: LoginUnlockContext) {
    report(
      UserEvent.Login(
        isBackupCode: context.isBackupCode,
        mode: .biometric,
        status: .errorWrongBiometric,
        verificationMode: context.verificationMode))
  }
}

extension BiometryUnlockStateMachine {
  public static var mock: BiometryUnlockStateMachine {
    BiometryUnlockStateMachine(
      unlocker: .mock(), keychainService: .mock(), login: Login("_"),
      loginSettings: .mock(secureLockMode: .biometry(.faceId)), logger: .mock,
      context: .init(origin: .lock, localLoginContext: .passwordApp), activityReporter: .mock)
  }
}
