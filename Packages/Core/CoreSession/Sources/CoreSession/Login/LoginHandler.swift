import Foundation
import DashTypes
import SwiftTreats
import DashlaneAPI

public class LoginHandler {
    public enum Error: Swift.Error {
        case loginDoesNotExist
        case cantAutologin
    }

    public enum LoginResult {
        case localLoginRequired(LocalLoginHandler)
        case remoteLoginRequired(RegularRemoteLoginHandler)
        case ssoAccountCreation(_ login: Login, SSOLoginInfo)
        case deviceToDeviceRemoteLogin(DeviceToDeviceLoginHandler)
    }

    let logger: Logger
    let sessionsContainer: SessionsContainerProtocol
    let deviceInfo: DeviceInfo
    let removeLocalData: (Login) -> Void
    let cryptoEngineProvider: CryptoEngineProvider
    let appApiClient: AppAPIClient
    public convenience init(sessionsContainer: SessionsContainerProtocol,
                            appApiClient: AppAPIClient,
                            apiClient: DeprecatedCustomAPIClient,
                            deviceInfo: DeviceInfo,
                            logger: Logger,
                            cryptoEngineProvider: CryptoEngineProvider,
                            removeLocalDataHandler: @escaping (Login) -> Void) {
        self.init(sessionsContainer: sessionsContainer,
                  appApiClient: appApiClient,
                  deviceInfo: deviceInfo,
                  logger: logger,
                  cryptoEngineProvider: cryptoEngineProvider,
                  removeLocalDataHandler: removeLocalDataHandler)
    }

    init(sessionsContainer: SessionsContainerProtocol,
         appApiClient: AppAPIClient,
         deviceInfo: DeviceInfo,
         logger: Logger,
         workingQueue: DispatchQueue = DispatchQueue.global(qos: .userInitiated),
         cryptoEngineProvider: CryptoEngineProvider,
         removeLocalDataHandler: @escaping (Login) -> Void) {

        self.sessionsContainer = sessionsContainer
        self.appApiClient = appApiClient
        self.deviceInfo = deviceInfo
        self.logger = logger
        self.removeLocalData = removeLocalDataHandler
        self.cryptoEngineProvider = cryptoEngineProvider
    }

            private func deleteLocalDataForUnregisteredLogins(login: Login, deviceAccessKey: String, logins: [Login]) async throws -> ([Login], SSOInfo?) {
        do {
            let profiles = logins.map { AuthenticationGetMethodsForLoginProfiles(login: $0.email, deviceAccessKey: deviceAccessKey)}
            let response = try await appApiClient.authentication.getAuthenticationMethodsForLogin(login: login.email, deviceAccessKey: deviceAccessKey, methods: [.totp, .duoPush, .dashlaneAuthenticator, .emailToken], profiles: profiles, timeout: 1)
            let profilesToDelete = response.profilesToDelete ?? []
            let logins = profilesToDelete.map {
                Login($0.login)
            }
            logins.forEach {
                self.removeLocalData($0)
            }
            return (logins, response.verifications.ssoInfo)
        } catch let error as DashlaneAPI.APIError where error.hasAuthenticationCode(.clientVersionDoesNotSupportSsoMigration) {
            throw AccountError.ssoMigrationNotSupported
        } catch let error as DashlaneAPI.APIError where error.hasAuthenticationCode(.deviceDeactivated) {
                        self.removeLocalData(login)
            return ([login], nil)
        } catch {
                        return ([], nil)
        }
    }

                    @MainActor
    public func createLocalLoginHandler(using login: Login,
                                        deviceId: String,
                                        context: LoginContext?) async throws -> LocalLoginHandler {
        guard let loginHandler = LocalLoginHandler(login: login,
                                                   deviceInfo: deviceInfo,
                                                   deviceId: deviceId,
                                                   sessionsContainer: sessionsContainer,
                                                   appAPIClient: appApiClient,
                                                   context: context,
                                                   logger: logger,
                                                   cryptoEngineProvider: cryptoEngineProvider) else {
            throw AccountError.unknown
        }

        await loginHandler.configureFirstStep()

        guard let deviceAccessKey = try? self.sessionsContainer.info(for: login).deviceAccessKey ?? deviceId else {
            return loginHandler
        }

        let (deletedLogins, ssoMigration) = try await self.deleteLocalDataForUnregisteredLogins(login: login, deviceAccessKey: deviceAccessKey, logins: [login])
        loginHandler.ssoInfo = ssoMigration
        guard !deletedLogins.contains(login) else {
            throw AccountError.unknown
        }
        return loginHandler
    }

        public func createRemoteLoginHandler(using login: Login, context: LoginContext?, cryptoEngineProvider: CryptoEngineProvider, accountInfo: AppAPIClient.Authentication.GetAuthenticationMethodsForDevice.Response) async throws -> RegularRemoteLoginHandler {

        guard let method = accountInfo.verifications.loginMethod(for: login, with: context) else {
            throw Error.loginDoesNotExist
        }

        let remoteHandler = RegularRemoteLoginHandler(login: login,
                                                      deviceRegistrationMethod: method,
                                                      deviceInfo: self.deviceInfo,
                                                      ssoInfo: accountInfo.verifications.ssoInfo,
                                                      appAPIClient: appApiClient,
                                                      sessionsContainer: self.sessionsContainer,
                                                      context: context,
                                                      logger: self.logger,
                                                      cryptoEngineProvider: cryptoEngineProvider)
        return remoteHandler
    }

    private func accountInfo(for login: Login) async throws -> AppAPIClient.Authentication.GetAuthenticationMethodsForDevice.Response {
        let accountInfo = try await appApiClient.authentication.getAuthenticationMethodsForDevice(login: login.email, methods: [.emailToken, .totp, .duoPush, .dashlaneAuthenticator])
        return accountInfo
    }

    public func createSession(with configuration: SessionConfiguration, cryptoConfig: CryptoRawConfig) async throws -> Session {
                self.removeLocalData(configuration.login)

		return try self.sessionsContainer.createSession(with: configuration, cryptoConfig: cryptoConfig)
    }

            public func login(using login: Login,
                      deviceId: String,
                      context: LoginContext?) async throws -> LoginResult {
        do {
            let localLoginHandler = try await createLocalLoginHandler(using: login, deviceId: deviceId, context: context)
            return LoginResult.localLoginRequired(localLoginHandler)
        } catch let error as AccountError where error == .ssoMigrationNotSupported {
            throw error
        } catch {
            let accountInfo = try await accountInfo(for: login)
            switch accountInfo.accountType {
            case .invisibleMasterPassword:
                let handler = makeDeviceToDeviceLoginHandler(login: login, context: context)
                return LoginResult.deviceToDeviceRemoteLogin(handler)
            default:
                let result = try await self.createRemoteLoginHandler(using: login, context: context, cryptoEngineProvider: self.cryptoEngineProvider, accountInfo: accountInfo)
                return LoginResult.remoteLoginRequired(result)
            }
        }
    }

    public func makeDeviceToDeviceLoginHandler(login: Login? = nil, context: LoginContext?) -> DeviceToDeviceLoginHandler {
        return DeviceToDeviceLoginHandler(login: login,
                                          deviceInfo: deviceInfo,
                                          apiClient: appApiClient,
                                          sessionsContainer: sessionsContainer,
                                          logger: logger,
                                          cryptoEngineProvider: self.cryptoEngineProvider,
                                          context: context)
    }
}

public extension LoginHandler {
    static var mock: LoginHandler {
        LoginHandler(sessionsContainer: FakeSessionsContainer(), appApiClient: .fake, deviceInfo: .mock, logger: LoggerMock(), cryptoEngineProvider: FakeCryptoEngineProvider(), removeLocalDataHandler: {_ in})
    }
}
