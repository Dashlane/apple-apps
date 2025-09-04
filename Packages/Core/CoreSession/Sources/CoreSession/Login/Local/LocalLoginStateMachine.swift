import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import StateMachine
import UserTrackingFoundation

public struct LocalLoginStateMachine: StateMachine {

  @Loggable
  public enum Error: Swift.Error {
    case wrongMasterKey
    case ssoLoginRequired
    case noServerKey
    case deviceDeactivated
    case couldNotFetchSSOInfo
    case unknown
  }

  public var state: State = .initial

  public var deviceAccessKey: String {
    return info.deviceAccessKey ?? self.deviceId
  }

  public var accountType: AccountType {
    info.accountType
  }

  @Loggable
  public enum State: Hashable, Sendable {
    case initial
    case needsThirdPartyOTP(
      ThirdPartyOTPOption, SecureLockMode, DeviceInfo, SSOAuthenticationInfo? = nil)
    case userUnlock(UserUnlockInfo)
    case ssoAuthenticationNeeded(
      SSOLocalStateMachine.State, SSOAuthenticationInfo, _ deviceAccessKey: String)
    case completed(LocalLoginConfiguration)
    case failed(StateMachineError)
    case cancelled
    case migrateAccount(AccountMigrationInfos)
    case logout
  }

  @Loggable
  public enum Event: Sendable {
    case getLoginType
    case otpDidFinish(authTicket: AuthTicket, SecureLockMode, isBackUpCode: Bool)
    case validateSSO(SSOKeys)
    case errorEncountered(StateMachineError)
    case completed(LocalLoginConfiguration)
    case cancel
    case logout
  }

  public let login: Login
  let cryptoEngineProvider: CryptoEngineProvider
  let deviceInfo: DeviceInfo
  let logger: Logger
  let info: SessionInfo
  let deviceId: String
  let appAPIClient: AppAPIClient
  let sessionsContainer: SessionsContainerProtocol
  let keychainService: AuthenticationKeychainServiceProtocol
  public let settings: LoginSettings
  let sessionCleaner: SessionCleanerProtocol
  let nitroAPIClient: NitroSSOAPIClient
  let checkIsBiometricSetIntact: Bool
  let activityReporter: ActivityReporterProtocol

  public init(
    login: Login,
    deviceInfo: DeviceInfo,
    deviceId: String,
    checkIsBiometricSetIntact: Bool = true,
    appAPIClient: AppAPIClient,
    nitroAPIClient: NitroSSOAPIClient,
    logger: Logger,
    cryptoEngineProvider: CryptoEngineProvider,
    settingsProvider: LoginSettingsProvider,
    keychainService: AuthenticationKeychainServiceProtocol,
    sessionCleaner: SessionCleanerProtocol,
    sessionsContainer: SessionsContainerProtocol,
    activityReporter: ActivityReporterProtocol
  ) throws {
    self.login = login
    self.logger = logger
    self.state = .initial
    self.sessionsContainer = sessionsContainer
    self.info = try sessionsContainer.info(for: login)
    self.deviceId = deviceId
    self.checkIsBiometricSetIntact = checkIsBiometricSetIntact
    self.appAPIClient = appAPIClient
    self.cryptoEngineProvider = cryptoEngineProvider
    self.keychainService = keychainService
    self.sessionCleaner = sessionCleaner
    self.deviceInfo = deviceInfo
    self.nitroAPIClient = nitroAPIClient
    self.activityReporter = activityReporter
    self.settings = try settingsProvider.makeSettings(for: login)
  }

  public mutating func transition(with event: Event) async throws {
    logger.info("Received event \(event)")
    switch (state, event) {
    case (.initial, .getLoginType):
      await computeLoginType()
    case (
      .needsThirdPartyOTP(_, _, _, let ssoInfo),
      let .otpDidFinish(authTicket, lockType, isBackupCode)
    ):
      await otpDidFinish(
        with: authTicket, lockType: lockType, isBackupCode: isBackupCode, ssoInfo: ssoInfo)
    case (let .ssoAuthenticationNeeded(_, ssoInfo, _), let .validateSSO(ssoKeys)):
      await validate(ssoKeys, ssoInfo: ssoInfo)
    case (let .userUnlock(unlockInfo), let .completed(session)):
      checkForMigration(session, ssoInfo: unlockInfo.ssoInfo)
    case (_, let .errorEncountered(error)):
      self.state = .failed(error)
    case (_, .cancel):
      self.state = .cancelled
    case (_, .logout):
      self.state = .logout
    case (_, let .completed(config)):
      self.state = .completed(config)
    default:
      let errorMessage: LogMessage = "Unexpected \(event) event for the state \(state)"
      logger.fatal(errorMessage)
      throw InvalidTransitionError<Self>(event: event, state: state)
    }
    let state = state
    logger.info("Transition to state: \(state)")
  }

  mutating private func computeLoginType() async {
    let lockType = settings.secureLockMode(checkIsBiometricSetIntact: checkIsBiometricSetIntact)
    do {
      let ssoInfo = try await fetchLoginInfo()
      switch self.info.accountType {
      case .masterPassword:
        if case .masterKey = lockType, let option = self.info.loginOTPOption {
          self.state = .needsThirdPartyOTP(option, lockType, deviceInfo, ssoInfo)
        } else if let option = self.info.loginOTPOption {
          if let serverKey = keychainService.serverKey(for: login) {
            state = .userUnlock(
              .init(
                accountType: self.info.accountType, secureLockMode: lockType, serverKey: serverKey,
                ssoInfo: ssoInfo))
          } else {
            self.state = .needsThirdPartyOTP(option, lockType, deviceInfo, ssoInfo)
          }
        } else {
          state = .userUnlock(
            .init(accountType: self.info.accountType, secureLockMode: lockType, ssoInfo: ssoInfo))
        }
      case .invisibleMasterPassword:
        state = .userUnlock(
          .init(accountType: self.info.accountType, secureLockMode: lockType, ssoInfo: ssoInfo))

      case .sso:
        await computeSSOLoginType(with: lockType, ssoInfo: ssoInfo)
      }
    } catch let error as Error where error == Error.deviceDeactivated {
      state = .logout
    } catch {
      state = .failed(StateMachineError(underlyingError: error))
      logger.error("Couldn't fetch login info:", error: error)
    }
  }

  mutating private func computeSSOLoginType(
    with lockType: SecureLockMode, ssoInfo: SSOAuthenticationInfo?
  ) async {
    switch lockType {
    case .masterKey:
      let ssoAuthenticationInfo =
        if ssoInfo != nil {
          ssoInfo
        } else {
          try? await fetchLoginInfo()
        }
      guard let ssoAuthenticationInfo else {
        state = .failed(StateMachineError(underlyingError: Error.couldNotFetchSSOInfo))
        return
      }
      self.state = .ssoAuthenticationNeeded(
        .waitingForUserInput, ssoAuthenticationInfo, deviceAccessKey)
    default:
      state = .userUnlock(
        .init(accountType: self.info.accountType, secureLockMode: lockType, ssoInfo: ssoInfo))

    }
  }

  mutating private func otpDidFinish(
    with authTicket: AuthTicket, lockType: SecureLockMode, isBackupCode: Bool,
    ssoInfo: SSOAuthenticationInfo?
  ) async {
    do {
      let response = try await appAPIClient.authentication.completeLoginWithAuthTicket(
        login: login.email, deviceAccessKey: deviceAccessKey, authTicket: authTicket.value)
      guard let serverKey = response.serverKey else {
        throw Error.noServerKey
      }
      if case .masterKey = lockType {
      } else {
        saveServerKey(serverKey, hasLock: true)
      }
      state = .userUnlock(
        .init(
          accountType: self.info.accountType, secureLockMode: lockType, serverKey: serverKey,
          authTicket: authTicket, isBackupCode: isBackupCode, ssoInfo: ssoInfo))
    } catch {
      self.state = .failed(StateMachineError(underlyingError: Error.noServerKey))
    }
  }

  private func saveServerKey(_ serverKey: String, hasLock: Bool) {
    guard hasLock else {
      return
    }
    try? keychainService.saveServerKey(serverKey, for: login)
  }

  private mutating func validate(_ ssoKeys: SSOKeys, ssoInfo: SSOAuthenticationInfo?) async {
    do {
      let passwordUnlocker = LocalUnlockSessionHandler(
        login: self.login, sessionsContainer: sessionsContainer, logger: self.logger)
      let session = try await passwordUnlocker.unlock(with: .ssoKey(ssoKeys.keys.ssoKey))
      let config = LocalLoginConfiguration(
        session: session, shouldResetMP: false, shouldRefreshKeychainMasterKey: true,
        newMasterPassword: nil, authTicket: ssoKeys.authTicket, authenticationMode: .sso)
      checkForMigration(config, ssoInfo: ssoInfo)
    } catch {
      state = .failed(StateMachineError(underlyingError: Error.wrongMasterKey))
    }
  }

  private func fetchLoginInfo() async throws -> SSOAuthenticationInfo? {
    do {
      let profiles = [
        AuthenticationMethodsLoginProfiles(login: login.email, deviceAccessKey: deviceAccessKey)
      ]
      let response = try await appAPIClient.authentication.getAuthenticationMethodsForLogin(
        login: login.email, deviceAccessKey: deviceAccessKey,
        methods: [.totp, .duoPush, .emailToken], profiles: profiles, timeout: 1)
      let profilesToDelete = response.profilesToDelete ?? []
      let logins = profilesToDelete.map {
        Login($0.login)
      }
      logins.forEach {
        self.sessionCleaner.removeLocalData(for: $0)
      }
      guard !logins.contains(login) else {
        throw Error.deviceDeactivated
      }
      guard
        case let .loginViaSSO(ssoAuthenticationInfo) = response.verifications.loginMethod(
          for: self.login)
      else {
        return nil
      }
      return ssoAuthenticationInfo
    } catch let error as DashlaneAPI.APIError where error.hasAuthenticationCode(.deviceDeactivated)
    {
      logger.info("Device deactivated, logging out")
      self.sessionCleaner.removeLocalData(for: login)
      throw Error.deviceDeactivated
    } catch {
      logger.info(
        "We ignore the error: \(error) for getAuthenticationMethodsForLogin and continue the local login flow"
      )
      return nil
    }
  }

  mutating func checkForMigration(
    _ configuration: LocalLoginConfiguration, ssoInfo: SSOAuthenticationInfo?
  ) {
    if let ssoInfo, let type = ssoInfo.migration {
      self.state = .migrateAccount(
        AccountMigrationInfos(
          session: configuration.session,
          type: type,
          ssoAuthenticationInfo: ssoInfo,
          authTicket: configuration.authTicket))
      return
    }
    state = .completed(configuration)
  }
}

public struct LocalUnlockSessionHandler: UnlockSessionHandler {
  let login: Login
  let sessionsContainer: SessionsContainerProtocol
  let logger: Logger

  public init(
    login: Login,
    sessionsContainer: SessionsContainerProtocol,
    logger: Logger
  ) {
    self.login = login
    self.sessionsContainer = sessionsContainer
    self.logger = logger
  }

  @discardableResult
  public func unlock(with masterKey: MasterKey) async throws -> Session {
    let loadInfo = LoadSessionInformation(
      login: login,
      masterKey: masterKey)
    let logger = self.logger
    do {
      let session = try sessionsContainer.loadSession(for: loadInfo)
      logger.debug("Loaded local session with crypto")
      return session
    } catch SessionsContainerError.cannotDecypherLocalKey {
      throw LocalLoginStateMachine.Error.wrongMasterKey
    }
  }
}

extension LocalLoginStateMachine {
  public func makeLocalLoginUnlockStateMachine(
    userUnlockInfo: UserUnlockInfo, attempts: PinCodeAttemptsProtocol
  ) -> LocalLoginUnlockStateMachine {
    LocalLoginUnlockStateMachine(
      login: login,
      userUnlockInfo: userUnlockInfo,
      deviceAccessKey: deviceAccessKey,
      attempts: attempts,
      sessionCleaner: sessionCleaner,
      unlocker: LocalUnlockSessionHandler(
        login: login, sessionsContainer: sessionsContainer, logger: logger),
      appAPIClient: appAPIClient,
      nitroAPIClient: nitroAPIClient,
      sessionsContainer: sessionsContainer,
      keychainService: keychainService,
      loginSettings: settings,
      cryptoEngineProvider: cryptoEngineProvider,
      activityReporter: activityReporter,
      logger: logger)
  }

  public func makeSSOLocalStateMachine(
    state: SSOLocalStateMachine.State, ssoAuthenticationInfo: SSOAuthenticationInfo
  ) -> SSOLocalStateMachine {
    SSOLocalStateMachine(
      initialState: state, ssoAuthenticationInfo: ssoAuthenticationInfo,
      deviceAccessKey: deviceAccessKey, apiClient: appAPIClient,
      cryptoEngineProvider: cryptoEngineProvider, logger: logger)
  }

  public func makeAccountVerificationStateMachine(verificationMethod: VerificationMethod)
    -> AccountVerificationStateMachine
  {
    AccountVerificationStateMachine(
      state: .initialize, login: login, verificationMethod: verificationMethod,
      appAPIClient: appAPIClient, logger: logger)
  }
}

extension LocalLoginStateMachine {
  public static var mock: LocalLoginStateMachine {
    try! LocalLoginStateMachine(
      login: Login("_"),
      deviceInfo: .mock,
      deviceId: "deviceId",
      appAPIClient: .mock({}),
      nitroAPIClient: .fake,
      logger: .mock,
      cryptoEngineProvider: .mock(),
      settingsProvider: .mock(secureLockMode: .masterKey),
      keychainService: .mock,
      sessionCleaner: SessionCleanerMock(),
      sessionsContainer: .mock,
      activityReporter: .mock)
  }
}
public struct UserUnlockInfo: Hashable, Sendable {
  public let serverKey: String?
  public let authTicket: AuthTicket?
  public let accountType: AccountType
  public let secureLockMode: SecureLockMode
  public let isBackupCode: Bool
  public let ssoInfo: SSOAuthenticationInfo?
  public let verificationMode: Definition.VerificationMode

  public init(
    accountType: AccountType,
    secureLockMode: SecureLockMode,
    serverKey: String? = nil,
    authTicket: AuthTicket? = nil,
    isBackupCode: Bool = false,
    ssoInfo: SSOAuthenticationInfo? = nil,
    verificationMode: Definition.VerificationMode = .none
  ) {
    self.serverKey = serverKey
    self.authTicket = authTicket
    self.accountType = accountType
    self.secureLockMode = secureLockMode
    self.isBackupCode = isBackupCode
    self.ssoInfo = ssoInfo
    self.verificationMode = verificationMode
  }
}
