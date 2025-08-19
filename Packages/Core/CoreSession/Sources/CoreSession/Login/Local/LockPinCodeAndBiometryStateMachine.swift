import CoreTypes
import DashlaneAPI
import Foundation
import LocalAuthentication
import LogFoundation
import StateMachine
import SwiftTreats
import UserTrackingFoundation

public struct LockPinCodeAndBiometryStateMachine: StateMachine {

  public var state: State = .initial

  @Loggable
  public enum State: Hashable, Sendable {
    case initial
    case biometricAuthenticationRequested(Biometry)
    case authenticated(LocalLoginConfiguration)
    case pinRequested(afterFailure: Bool)
    case pinValidationFailed(attempts: Int)
    case authenticationFailed
    case recoveryStarted
    case cancelled
  }

  public enum Event: Sendable {
    case initialize
    case startBiometryAuthentication(String, String)
    case validateMasterKey
    case validatePIN(String)
    case recover
    case cancel
  }

  private let unlocker: UnlockSessionHandler
  private let login: Login
  private let pinCodeLock: SecureLockMode.PinCodeLock
  private let logger: Logger
  private let biometryValidator: BiometryValidatorProtocol
  private let pinCodeAttempts: PinCodeAttemptsProtocol
  private let biometry: Biometry?
  private let activityReporter: ActivityReporterProtocol
  private let context: LoginUnlockContext

  public init(
    unlocker: UnlockSessionHandler,
    login: Login,
    biometry: Biometry?,
    context: LoginUnlockContext,
    pinCodeLock: SecureLockMode.PinCodeLock,
    pinCodeAttempts: PinCodeAttemptsProtocol,
    biometryValidator: BiometryValidatorProtocol = BiometryValidator(),
    logger: Logger,
    activityReporter: ActivityReporterProtocol
  ) {
    self.unlocker = unlocker
    self.login = login
    self.pinCodeLock = pinCodeLock
    self.biometryValidator = biometryValidator
    self.logger = logger
    self.biometry = biometry
    self.pinCodeAttempts = pinCodeAttempts
    self.activityReporter = activityReporter
    self.context = context
  }

  public mutating func transition(with event: Event) async throws {
    logger.info("Received event \(event)")
    switch (state, event) {
    case (.initial, .initialize):
      if let biometryType = biometry {
        self.state = .biometricAuthenticationRequested(biometryType)
      } else {
        state = .pinRequested(afterFailure: false)
      }
    case (
      .biometricAuthenticationRequested(_),
      let .startBiometryAuthentication(reasonTitle, fallbackTitle)
    ):
      do {
        try await biometryValidator.authenticate(
          using: LAContext(), reasonTitle: reasonTitle, fallbackTitle: fallbackTitle)
        do {
          let session = try await unlocker.validateMasterKey(pinCodeLock.masterKey)
          self.state = .authenticated(
            LocalLoginConfiguration(session: session, authenticationMode: .biometry))
        } catch {
          logger.error("Master key validation for biometry failed")
          self.state = .pinRequested(afterFailure: true)
        }
      } catch {
        logger.error("biometry validation failed")
        self.state = .pinRequested(afterFailure: true)
      }
    case (_, let .validatePIN(pin)):
      await validatePin(pin)
    case (_, .recover):
      self.state = .recoveryStarted
    case (_, .cancel):
      self.state = .cancelled
    default:
      let errorMessage: LogMessage = "Unexpected \(event) event for the state \(state)"
      logger.fatal(errorMessage)
      throw InvalidTransitionError<Self>(event: event, state: state)
    }
    activityReporter.log(state, info: context)
    let state = state
    logger.info("Transition to state: \(state)")
  }

  mutating func validatePin(_ pincode: String) async {
    if pinCodeLock.code != pincode {
      pinCodeAttempts.addNewAttempt()
      guard pinCodeAttempts.tooManyAttempts else {
        state = .pinValidationFailed(attempts: pinCodeAttempts.count)
        return
      }
      logger.error("Pincode attempts limit reached")
      state = .authenticationFailed
    } else {
      do {
        let session = try await unlocker.validateMasterKey(pinCodeLock.masterKey)
        self.state = .authenticated(
          LocalLoginConfiguration(session: session, authenticationMode: .pincode))
      } catch {
        self.state = .authenticationFailed
      }
    }
  }
}
extension LockPinCodeAndBiometryStateMachine {
  public static var mock: LockPinCodeAndBiometryStateMachine {
    LockPinCodeAndBiometryStateMachine(
      unlocker: .mock(),
      login: Login("_"),
      biometry: .faceId,
      context: .init(origin: .login, localLoginContext: .passwordApp),
      pinCodeLock: .init(code: "123456", masterKey: .masterPassword("_", serverKey: nil)),
      pinCodeAttempts: .mock,
      logger: .mock,
      activityReporter: .mock)
  }
}

extension ActivityReporterProtocol {
  fileprivate func log(_ state: LockPinCodeAndBiometryStateMachine.State, info: LoginUnlockContext)
  {
    switch state {
    case .biometricAuthenticationRequested:
      report(
        UserEvent.AskAuthentication(
          mode: .biometric,
          reason: .login,
          verificationMode: info.verificationMode))
    case let .pinRequested(afterFailure):
      if afterFailure {
        report(
          UserEvent.Login(
            isBackupCode: info.isBackupCode,
            mode: .biometric,
            status: .errorWrongBiometric,
            verificationMode: info.verificationMode))
      }
      report(
        UserEvent.AskAuthentication(
          mode: .pin,
          reason: .login,
          verificationMode: info.verificationMode))
    case .pinValidationFailed:
      report(
        UserEvent.Login(
          isBackupCode: info.isBackupCode,
          mode: .pin,
          status: .errorWrongPin,
          verificationMode: info.verificationMode))
    default:
      break
    }
  }

}
