import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import SwiftTreats
import UserTrackingFoundation

public class LoginStateMachine {
  public enum Error: Swift.Error {
    case loginDoesNotExist
    case cantAutologin
  }

  public enum LoginResult {
    case localLoginRequired(LocalLoginStateMachine)
    case remoteLoginRequired(Login, LoginMethod, DeviceInfo)
    case ssoAccountCreation(_ login: Login, SSOLoginInfo)
    case deviceToDeviceRemoteLogin(Login?, DeviceInfo)
  }

  let logger: Logger
  let sessionsContainer: SessionsContainerProtocol
  public let deviceInfo: DeviceInfo
  let sessionCleaner: SessionCleanerProtocol
  let cryptoEngineProvider: CryptoEngineProvider
  let appApiClient: AppAPIClient
  let keychainService: AuthenticationKeychainServiceProtocol
  let loginSettingsProvider: LoginSettingsProvider
  let nitroAPIClient: NitroSSOAPIClient
  let activityReporter: ActivityReporterProtocol
  let remoteLogger: RemoteLogger

  public init(
    sessionsContainer: SessionsContainerProtocol,
    appApiClient: AppAPIClient,
    nitroAPIClient: NitroSSOAPIClient,
    deviceInfo: DeviceInfo,
    logger: Logger,
    workingQueue: DispatchQueue = DispatchQueue.global(qos: .userInitiated),
    cryptoEngineProvider: CryptoEngineProvider,
    keychainService: AuthenticationKeychainServiceProtocol,
    loginSettingsProvider: LoginSettingsProvider,
    sessionCleaner: SessionCleanerProtocol,
    activityReporter: ActivityReporterProtocol,
    remoteLogger: RemoteLogger
  ) {
    self.sessionsContainer = sessionsContainer
    self.appApiClient = appApiClient
    self.deviceInfo = deviceInfo
    self.logger = logger
    self.sessionCleaner = sessionCleaner
    self.cryptoEngineProvider = cryptoEngineProvider
    self.keychainService = keychainService
    self.loginSettingsProvider = loginSettingsProvider
    self.nitroAPIClient = nitroAPIClient
    self.activityReporter = activityReporter
    self.remoteLogger = remoteLogger
  }

  public func createLocalLoginStateMachine(
    using login: Login,
    deviceId: String,
    checkIsBiometricSetIntact: Bool = true
  ) throws -> LocalLoginStateMachine {

    return try LocalLoginStateMachine(
      login: login,
      deviceInfo: deviceInfo,
      deviceId: deviceId,
      checkIsBiometricSetIntact: checkIsBiometricSetIntact,
      appAPIClient: appApiClient,
      nitroAPIClient: nitroAPIClient,
      logger: logger,
      cryptoEngineProvider: cryptoEngineProvider,
      settingsProvider: loginSettingsProvider,
      keychainService: keychainService,
      sessionCleaner: sessionCleaner,
      sessionsContainer: sessionsContainer,
      activityReporter: activityReporter)
  }

  private func accountInfo(for login: Login) async throws
    -> AppAPIClient.Authentication.GetAuthenticationMethodsForDevice.Response
  {
    let accountInfo = try await appApiClient.authentication.getAuthenticationMethodsForDevice(
      login: login.email, methods: [.emailToken, .totp, .duoPush])
    return accountInfo
  }

  public func login(
    using login: Login,
    deviceId: String
  ) async throws -> LoginResult {
    do {
      let localLoginStateMachine = try createLocalLoginStateMachine(
        using: login, deviceId: deviceId)
      return LoginResult.localLoginRequired(localLoginStateMachine)
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

extension LoginStateMachine {
  public static var mock: LoginStateMachine {
    LoginStateMachine(
      sessionsContainer: .mock,
      appApiClient: .fake,
      nitroAPIClient: .fake,
      deviceInfo: .mock,
      logger: .mock,
      cryptoEngineProvider: .mock(),
      keychainService: .mock(),
      loginSettingsProvider: .mock(secureLockMode: .biometry(.faceId)),
      sessionCleaner: SessionCleanerMock(),
      activityReporter: .mock,
      remoteLogger: .mock)
  }
}

extension LoginStateMachine {
  public func makeRemoteLoginStateMachine(type: RemoteLoginType) -> RemoteLoginStateMachine {
    RemoteLoginStateMachine(
      type: type, deviceInfo: deviceInfo, apiclient: appApiClient,
      sessionsContainer: sessionsContainer, sessionCleaner: sessionCleaner, logger: logger,
      cryptoEngineProvider: cryptoEngineProvider, remoteLogger: remoteLogger)
  }
}
