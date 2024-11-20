import DashTypes
import DashlaneAPI
import Foundation
import SwiftTreats

@MainActor
public class LoginHandler {
  public enum Error: Swift.Error {
    case loginDoesNotExist
    case cantAutologin
  }

  public enum LoginResult {
    case localLoginRequired(LocalLoginHandler)
    case remoteLoginRequired(Login, LoginMethod, DeviceInfo)
    case ssoAccountCreation(_ login: Login, SSOLoginInfo)
    case deviceToDeviceRemoteLogin(Login?, DeviceInfo)
  }

  let logger: Logger
  let sessionsContainer: SessionsContainerProtocol
  public let deviceInfo: DeviceInfo
  let removeLocalData: (Login) -> Void
  let cryptoEngineProvider: CryptoEngineProvider
  let appApiClient: AppAPIClient

  public init(
    sessionsContainer: SessionsContainerProtocol,
    appApiClient: AppAPIClient,
    deviceInfo: DeviceInfo,
    logger: Logger,
    workingQueue: DispatchQueue = DispatchQueue.global(qos: .userInitiated),
    cryptoEngineProvider: CryptoEngineProvider,
    removeLocalDataHandler: @escaping (Login) -> Void
  ) {

    self.sessionsContainer = sessionsContainer
    self.appApiClient = appApiClient
    self.deviceInfo = deviceInfo
    self.logger = logger
    self.removeLocalData = removeLocalDataHandler
    self.cryptoEngineProvider = cryptoEngineProvider
  }

  private func deleteLocalDataForUnregisteredLogins(
    login: Login, deviceAccessKey: String, logins: [Login]
  ) async throws -> ([Login], SSOInfo?) {
    do {
      let profiles = logins.map {
        AuthenticationMethodsLoginProfiles(login: $0.email, deviceAccessKey: deviceAccessKey)
      }
      let response = try await appApiClient.authentication.getAuthenticationMethodsForLogin(
        login: login.email, deviceAccessKey: deviceAccessKey,
        methods: [.totp, .duoPush, .emailToken], profiles: profiles, timeout: 1)
      let profilesToDelete = response.profilesToDelete ?? []
      let logins = profilesToDelete.map {
        Login($0.login)
      }
      logins.forEach {
        self.removeLocalData($0)
      }
      return (logins, response.verifications.ssoInfo)
    } catch let error as DashlaneAPI.APIError where error.hasAuthenticationCode(.deviceDeactivated)
    {
      self.removeLocalData(login)
      return ([login], nil)
    } catch {
      return ([], nil)
    }
  }

  @MainActor
  public func createLocalLoginHandler(
    using login: Login,
    deviceId: String
  ) async throws -> LocalLoginHandler {
    guard
      let loginHandler = LocalLoginHandler(
        login: login,
        deviceInfo: deviceInfo,
        deviceId: deviceId,
        sessionsContainer: sessionsContainer,
        appAPIClient: appApiClient,
        logger: logger,
        cryptoEngineProvider: cryptoEngineProvider)
    else {
      throw AccountError.unknown
    }

    try await loginHandler.configureFirstStep()

    guard
      let deviceAccessKey = try? self.sessionsContainer.info(for: login).deviceAccessKey ?? deviceId
    else {
      return loginHandler
    }

    let (deletedLogins, ssoMigration) = try await self.deleteLocalDataForUnregisteredLogins(
      login: login, deviceAccessKey: deviceAccessKey, logins: [login])
    loginHandler.ssoInfo = ssoMigration
    guard !deletedLogins.contains(login) else {
      throw AccountError.unknown
    }
    return loginHandler
  }

  private func accountInfo(for login: Login) async throws
    -> AppAPIClient.Authentication.GetAuthenticationMethodsForDevice.Response
  {
    let accountInfo = try await appApiClient.authentication.getAuthenticationMethodsForDevice(
      login: login.email, methods: [.emailToken, .totp, .duoPush])
    return accountInfo
  }

  public func createSession(with configuration: SessionConfiguration, cryptoConfig: CryptoRawConfig)
    async throws -> Session
  {
    self.removeLocalData(configuration.login)

    return try self.sessionsContainer.createSession(with: configuration, cryptoConfig: cryptoConfig)
  }

  public func login(
    using login: Login,
    deviceId: String
  ) async throws -> LoginResult {
    do {
      let localLoginHandler = try await createLocalLoginHandler(using: login, deviceId: deviceId)
      return LoginResult.localLoginRequired(localLoginHandler)
    } catch {
      let accountInfo = try await accountInfo(for: login)
      switch accountInfo.accountType {
      case .invisibleMasterPassword:
        return LoginResult.deviceToDeviceRemoteLogin(login, deviceInfo)
      default:
        guard let method = accountInfo.verifications.loginMethod(for: login) else {
          throw Error.loginDoesNotExist
        }
        return LoginResult.remoteLoginRequired(login, method, deviceInfo)
      }
    }
  }
}

extension LoginHandler {
  public static var mock: LoginHandler {
    LoginHandler(
      sessionsContainer: FakeSessionsContainer(), appApiClient: .fake, deviceInfo: .mock,
      logger: LoggerMock(), cryptoEngineProvider: FakeCryptoEngineProvider(),
      removeLocalDataHandler: { _ in })
  }
}
