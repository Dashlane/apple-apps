import DashTypes
import DashlaneAPI
import Foundation
import SwiftTreats

@MainActor
public class LocalLoginHandler {

  public enum Step {
    case initialize
    case validateThirdPartyOTP(ThirdPartyOTPOption)
    case migrateAccount(AccountMigrationInfos)
    case unlock(UnlockSessionHandler, UnlockType)
    case migrateAnalyticsId(Session)
    case migrateSSOKeys(SSOKeysMigrationType)
    case completed(Session, isRecoveryLogin: Bool)
  }

  public enum Error: Swift.Error {
    case wrongMasterKey
    case ssoLoginRequired
    case noServerKey
  }

  public internal(set) var step: Step = .initialize

  private let logger: Logger
  public let login: Login
  let sessionsContainer: SessionsContainerProtocol
  let appAPIClient: AppAPIClient
  let deviceId: String
  public let deviceInfo: DeviceInfo
  var ssoInfo: SSOInfo?
  var loginMethod: LoginMethod?

  public var deviceAccessKey: String {
    return info.deviceAccessKey ?? self.deviceId
  }

  private let info: SessionInfo
  public let cryptoEngineProvider: CryptoEngineProvider

  public var accountType: AccountType {
    info.accountType
  }

  init?(
    login: Login,
    deviceInfo: DeviceInfo,
    deviceId: String,
    sessionsContainer: SessionsContainerProtocol,
    appAPIClient: AppAPIClient,
    logger: Logger,
    cryptoEngineProvider: CryptoEngineProvider
  ) {

    do {
      let info = try sessionsContainer.info(for: login)
      self.logger = logger
      self.login = login
      self.deviceInfo = deviceInfo
      self.info = info
      self.sessionsContainer = sessionsContainer
      self.appAPIClient = appAPIClient
      self.deviceId = deviceId
      self.cryptoEngineProvider = cryptoEngineProvider
    } catch {
      logger.error("Local Handler failed to init for login \(login)", error: error)
      return nil
    }
  }

  func configureFirstStep() async throws {
    if let option = self.info.loginOTPOption {
      self.step = .validateThirdPartyOTP(option)
    } else if self.info.accountType == .sso {
      do {
        let response = try await self.appAPIClient.authentication.getAuthenticationMethodsForLogin(
          login: self.login.email,
          deviceAccessKey: self.deviceAccessKey,
          methods: [.emailToken, .totp, .duoPush],
          profiles: [
            AuthenticationMethodsLoginProfiles(
              login: self.login.email,
              deviceAccessKey: deviceAccessKey
            )
          ],
          u2fSecret: nil
        )
        self.loginMethod = response.verifications.loginMethod(for: self.login)
      } catch {}

      if case let .loginViaSSO(ssoAuthenticationInfo) = self.loginMethod {
        self.moveToUnlockStep(with: .ssoValidation(ssoAuthenticationInfo))
      } else {
        throw AccountError.unknown
      }
    } else {
      self.moveToUnlockStep(with: .mpValidation)
    }
  }

  public func moveToUnlockStep(with type: UnlockType) {
    let passwordUnlocker = UnlockAndLoadLocalSession(
      localLoginHandler: self, type: type, logger: logger)
    step = .unlock(passwordUnlocker, type)
  }

  public func validateSSOKey(_ ssoKeys: SSOKeys, ssoAuthenticationInfo: SSOAuthenticationInfo)
    async throws
  {
    let passwordUnlocker = UnlockAndLoadLocalSession(
      localLoginHandler: self,
      type: .ssoValidation(
        ssoAuthenticationInfo, authTicket: ssoKeys.authTicket, remoteKey: ssoKeys.remoteKey),
      logger: logger)
    try await passwordUnlocker.unlock(with: .ssoKey(ssoKeys.ssoKey), isRecoveryLogin: false)
  }

  public func login(withAuthTicket authTicket: AuthTicket) async throws -> String {
    let response = try await appAPIClient.authentication.completeLoginWithAuthTicket(
      login: login.email, deviceAccessKey: deviceAccessKey, authTicket: authTicket.value)
    guard let serverKey = response.serverKey else {
      throw Error.noServerKey
    }
    moveToUnlockStep(with: .mpOtp2Validation(authTicket: authTicket, serverKey: serverKey))
    return serverKey
  }

  public func finish(with session: Session, isRecoveryLogin: Bool) {
    step = .completed(session, isRecoveryLogin: isRecoveryLogin)
  }
}

internal struct UnlockAndLoadLocalSession: UnlockSessionHandler {
  let localLoginHandler: LocalLoginHandler
  let type: UnlockType
  let logger: Logger

  func unlock(
    with masterKey: MasterKey,
    isRecoveryLogin: Bool
  ) async throws {
    var masterKey = masterKey
    if case let UnlockType.mpOtp2Validation(_, serverKey) = type {
      masterKey = masterKey.masterKey(withServerKey: serverKey)
    }
    let loadInfo = LoadSessionInformation(
      login: localLoginHandler.login,
      masterKey: masterKey)
    let logger = self.logger
    do {
      let session = try localLoginHandler.sessionsContainer.loadSession(for: loadInfo)
      logger.debug("Loaded local session with crypto")
      await MainActor.run {
        self.localLoginHandler.step = type.localLoginStep(
          with: localLoginHandler, session: session,
          cryptoEngineProvider: localLoginHandler.cryptoEngineProvider,
          isRecoveryLogin: isRecoveryLogin)
      }
    } catch SessionsContainerError.cannotDecypherLocalKey {
      if let step = type.localLoginStep(with: masterKey) {
        await MainActor.run {
          self.localLoginHandler.step = step
        }
      } else {
        throw LocalLoginHandler.Error.wrongMasterKey
      }
    }
  }
}

extension LocalLoginHandler {
  public static var mock: LocalLoginHandler {
    LocalLoginHandler(
      login: Login(""), deviceInfo: .mock, deviceId: "", sessionsContainer: FakeSessionsContainer(),
      appAPIClient: .fake, logger: LoggerMock(), cryptoEngineProvider: FakeCryptoEngineProvider())!
  }
}
