import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import StateMachine
import SwiftTreats
import UserTrackingFoundation

public struct LocalLoginUnlockStateMachine: StateMachine {

  public var state: State = .initialize

  @Loggable
  public enum State: Hashable, Sendable {
    case initialize
    case masterPassword(
      MasterPasswordLocalLoginStateMachine.State, Biometry?, MPUserAccountUnlockMode)
    case pincode(
      LockPinCodeAndBiometryStateMachine.State, pinCodeLock: SecureLockMode.PinCodeLock,
      biometry: Biometry?, AccountType)
    case biometry(BiometryUnlockStateMachine.State, Biometry, AccountType)
    case passwordLessRecovery(afterFailure: Bool)
    case sso(deviceAccessKey: String)
    case logout
    case completed(LocalLoginConfiguration)

    var logMode: Definition.Mode {
      switch self {
      case .masterPassword:
        return .masterPassword
      case .passwordLessRecovery:
        return .notSelected
      case .sso:
        return .sso
      default:
        return .notSelected
      }
    }
  }

  public enum Event: Sendable {
    case start
    case unlockFailed(Definition.Mode, Biometry? = nil)
    case handleSSOresult(SSOKeys)
    case cancel
    case logout
    case authenticated(LocalLoginConfiguration)
    case askBiometryForMasterPassword(Biometry)
  }

  let login: Login
  let deviceAccessKey: String
  let userUnlockInfo: UserUnlockInfo
  let attempts: PinCodeAttemptsProtocol
  let sessionCleaner: SessionCleanerProtocol
  let unlocker: UnlockSessionHandler
  let keychainService: AuthenticationKeychainServiceProtocol
  private let logger: Logger
  private var loginSettings: LoginSettings
  let appAPIClient: AppAPIClient
  let sessionsContainer: SessionsContainerProtocol
  let nitroAPIClient: NitroSSOAPIClient
  let cryptoEngineProvider: CryptoEngineProvider
  let activityReporter: ActivityReporterProtocol

  public init(
    login: Login,
    userUnlockInfo: UserUnlockInfo,
    deviceAccessKey: String,
    attempts: PinCodeAttemptsProtocol,
    sessionCleaner: SessionCleanerProtocol,
    unlocker: UnlockSessionHandler,
    appAPIClient: AppAPIClient,
    nitroAPIClient: NitroSSOAPIClient,
    sessionsContainer: SessionsContainerProtocol,
    keychainService: AuthenticationKeychainServiceProtocol,
    loginSettings: LoginSettings,
    cryptoEngineProvider: CryptoEngineProvider,
    activityReporter: ActivityReporterProtocol,
    logger: Logger
  ) {
    self.login = login
    self.userUnlockInfo = userUnlockInfo
    self.attempts = attempts
    self.sessionCleaner = sessionCleaner
    self.logger = logger
    self.deviceAccessKey = deviceAccessKey
    self.unlocker = unlocker
    self.keychainService = keychainService
    self.loginSettings = loginSettings
    self.appAPIClient = appAPIClient
    self.nitroAPIClient = nitroAPIClient
    self.sessionsContainer = sessionsContainer
    self.cryptoEngineProvider = cryptoEngineProvider
    self.activityReporter = activityReporter
  }

  public mutating func transition(with event: Event) async throws {
    logger.info("Received event \(event)")
    switch (state, event) {
    case (.initialize, .start):
      switch userUnlockInfo.secureLockMode {
      case let .biometry(biometry):
        state = .biometry(.initial, biometry, userUnlockInfo.accountType)
      case let .pincode(pinCodeLock):
        if attempts.tooManyAttempts {
          state = userUnlockInfo.fallbackUnlockMode(
            afterFailure: true, biometry: nil, deviceAccessKey: deviceAccessKey)
        } else {
          state = .pincode(
            .initial, pinCodeLock: pinCodeLock, biometry: nil, userUnlockInfo.accountType)
        }
      case let .biometryAndPincode(biometry, pinCodeLock):
        if attempts.tooManyAttempts {
          state = userUnlockInfo.fallbackUnlockMode(
            afterFailure: true, biometry: biometry, deviceAccessKey: deviceAccessKey)
        } else {
          state = .pincode(
            .initial, pinCodeLock: pinCodeLock, biometry: biometry, userUnlockInfo.accountType)
        }

      case .rememberMasterPassword:
        await unlockUsingRememberPassword()

      case .masterKey:
        state = userUnlockInfo.fallbackUnlockMode(
          afterFailure: false, biometry: nil, deviceAccessKey: deviceAccessKey)
      }
    case (_, let .unlockFailed(previousMode, biometry)):
      let newState = userUnlockInfo.fallbackUnlockMode(
        afterFailure: true, biometry: biometry, deviceAccessKey: deviceAccessKey)
      activityReporter.logAskOtherAuthentication(for: previousMode, nextMode: newState.logMode)
      state = newState
    case (_, let .handleSSOresult(ssoKeys)):
      do {
        let session = try await unlocker.validateMasterKey(.ssoKey(ssoKeys.keys.ssoKey))
        state = .completed(LocalLoginConfiguration(session: session, authenticationMode: .sso))
      } catch {
        state = userUnlockInfo.fallbackUnlockMode(
          afterFailure: true, biometry: nil, deviceAccessKey: deviceAccessKey)
      }
    case (_, .logout):
      sessionCleaner.removeLocalData(for: login)
      state = .logout
    case (_, .cancel):
      let unlockMethod = self.userUnlockInfo.fallbackUnlockMode(
        afterFailure: false, biometry: nil, deviceAccessKey: deviceAccessKey)
      switch unlockMethod {
      case .passwordLessRecovery:
        state = .logout
      default:
        state = unlockMethod
      }
    case (_, let .authenticated(config)):
      state = .completed(config)
    case (_, let .askBiometryForMasterPassword(biometry)):
      state = .biometry(.initial, biometry, .masterPassword)
    default:
      let errorMessage: LogMessage = "Unexpected \(event) event for the state \(state)"
      logger.fatal(errorMessage)
      throw InvalidTransitionError<Self>(event: event, state: state)
    }
    let state = state
    logger.info("Transition to state: \(state)")
  }

  mutating private func unlockUsingRememberPassword() async {
    guard !loginSettings.hasAutomaticallyLogout else {
      loginSettings.hasAutomaticallyLogout = false
      logger.info("User logged out manually last time")
      fallback()
      return
    }

    guard let masterKey = try? keychainService.masterKey(for: self.login, using: nil) else {
      logger.error("Master key not found in keychain for Remember MP")
      fallback()
      return
    }

    do {
      switch masterKey {
      case .masterPassword(let masterPassword):
        let session = try await unlocker.validateMasterKey(
          .masterPassword(masterPassword, serverKey: userUnlockInfo.serverKey))
        state = .completed(.init(session: session, authenticationMode: .rememberMasterPassword))

      case .key(let key):
        let session = try await unlocker.validateMasterKey(.ssoKey(key))
        state = .completed(.init(session: session, authenticationMode: .rememberMasterPassword))
      }
    } catch {
      logger.error("Remember MP: Master key validation failed")
      try? self.keychainService.removeMasterKey(for: self.login)
      fallback()
    }

    func fallback() {
      logger.info("Remember MP: Falling back to MP")
      let unlockMethod = self.userUnlockInfo.fallbackUnlockMode(
        afterFailure: false, biometry: nil, deviceAccessKey: deviceAccessKey)
      state = unlockMethod
    }
  }
}

extension UserUnlockInfo {
  func fallbackUnlockMode(afterFailure: Bool, biometry: Biometry?, deviceAccessKey: String)
    -> LocalLoginUnlockStateMachine.State
  {
    switch self.accountType {
    case .masterPassword:
      if let serverKey = serverKey {
        return .masterPassword(
          .initial, biometry,
          .twoFactor(serverKey: serverKey, accountRecoveryAuthTicket: authTicket))
      } else {
        return .masterPassword(.initial, biometry, .masterPasswordOnly)
      }
    case .invisibleMasterPassword:
      return .passwordLessRecovery(afterFailure: afterFailure)
    case .sso:
      return .sso(deviceAccessKey: deviceAccessKey)
    }
  }
}

extension LocalLoginUnlockStateMachine {

  public func makeMasterPasswordLocalLoginStateMachine(
    unlockMode: MPUserAccountUnlockMode,
    resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
    pinCodeattempts: PinCodeAttemptsProtocol, context: LoginUnlockContext
  ) -> MasterPasswordLocalLoginStateMachine {
    MasterPasswordLocalLoginStateMachine(
      login: login,
      unlocker: unlocker,
      context: context,
      appAPIClient: appAPIClient,
      cryptoEngineProvider: cryptoEngineProvider,
      resetMasterPasswordService: resetMasterPasswordService,
      pinCodeAttempts: pinCodeattempts,
      unlockMode: unlockMode,
      logger: logger,
      activityReporter: activityReporter)
  }

  public func makeBiometryUnlockStateMachine(context: LoginUnlockContext)
    -> BiometryUnlockStateMachine
  {
    BiometryUnlockStateMachine(
      unlocker: unlocker, keychainService: keychainService, login: login,
      loginSettings: loginSettings, logger: logger, context: context,
      activityReporter: activityReporter)
  }

  public func makeLockPinCodeAndBiometryStateMachine(
    pinCodeLock: SecureLockMode.PinCodeLock, pinCodeAttempts: PinCodeAttemptsProtocol,
    context: LoginUnlockContext, biometry: Biometry?
  ) -> LockPinCodeAndBiometryStateMachine {
    LockPinCodeAndBiometryStateMachine(
      unlocker: unlocker, login: login, biometry: biometry, context: context,
      pinCodeLock: pinCodeLock, pinCodeAttempts: pinCodeAttempts, logger: logger,
      activityReporter: activityReporter)
  }

  public func makeSSOUnlockStateMachine(state: SSOUnlockStateMachine.State) -> SSOUnlockStateMachine
  {
    SSOUnlockStateMachine(
      state: state, login: login, apiClient: appAPIClient, nitroClient: nitroAPIClient,
      deviceAccessKey: deviceAccessKey, cryptoEngineProvider: cryptoEngineProvider, logger: logger,
      activityReporter: activityReporter)
  }
}

extension ActivityReporterProtocol {
  fileprivate func logAskOtherAuthentication(for mode: Definition.Mode, nextMode: Definition.Mode) {
    report(UserEvent.AskUseOtherAuthentication(next: nextMode, previous: mode))
  }
}
