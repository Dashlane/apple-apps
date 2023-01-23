import Foundation
import DashTypes
import SwiftTreats

public class LoginHandler {
    public enum Error: Swift.Error {
        case loginDoesNotExist
        case cantAutologin
    }
    
    public enum LoginResult {
        case localLoginRequired(LocalLoginHandler)
        case remoteLoginRequired(RemoteLoginHandler)
        case ssoAccountCreation(_ login: Login, SSOLoginInfo)
    }
    
    let logger: Logger
    let sessionsContainer: SessionsContainerProtocol
    let accountAPIClient: AccountAPIClientProtocol
    let deviceInfo: DeviceInfo
    let removeLocalData: (Login) -> Void
    let workingQueue: DispatchQueue
    let cryptoEngineProvider: CryptoEngineProvider
    
    public convenience init(sessionsContainer: SessionsContainerProtocol,
                            apiClient: DeprecatedCustomAPIClient,
                            deviceInfo: DeviceInfo,
                            logger: Logger,
                            workingQueue: DispatchQueue = DispatchQueue.global(qos: .userInitiated),
                            cryptoEngineProvider: CryptoEngineProvider,
                            removeLocalDataHandler: @escaping (Login) -> Void) {
        let accountAPIClient = AccountAPIClient(apiClient: apiClient)
        self.init(sessionsContainer: sessionsContainer,
                  accountAPIClient: accountAPIClient,
                  deviceInfo: deviceInfo,
                  logger: logger,
                  cryptoEngineProvider: cryptoEngineProvider,
                  removeLocalDataHandler: removeLocalDataHandler)
    }
    
    init(sessionsContainer: SessionsContainerProtocol,
         accountAPIClient: AccountAPIClientProtocol,
         deviceInfo: DeviceInfo,
         logger: Logger,
         workingQueue: DispatchQueue = DispatchQueue.global(qos: .userInitiated),
         cryptoEngineProvider: CryptoEngineProvider,
         removeLocalDataHandler: @escaping (Login) -> Void) {
        
        self.sessionsContainer = sessionsContainer
        self.accountAPIClient = accountAPIClient
        self.deviceInfo = deviceInfo
        self.logger = logger
        self.removeLocalData = removeLocalDataHandler
        self.workingQueue = workingQueue
        self.cryptoEngineProvider = cryptoEngineProvider
    }
    
            private func deleteLocalDataForUnregisteredLogins(login: Login, deviceAccessKey: String, logins: [Login]) async throws -> ([Login], SSOInfo?) {
        do {
            let response = try await accountAPIClient.requestLogin(with: LoginRequestInfo(login: login.email, deviceAccessKey: deviceAccessKey, loginsToCheckForDeletion: logins), timeout: 1)
            let logins = response.profilesToDelete.map {
                Login($0.login)
            }
            logins.forEach {
                self.removeLocalData($0)
            }
            return (logins, response.ssoInfo)
        } catch let error as APIErrorResponse where error.errors.first?.accountError == .ssoMigrationNotSupported {
            throw AccountError.ssoMigrationNotSupported
        } catch let error as APIErrorResponse where error.errors.first?.accountError == .deviceDeactivated {
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
                                                   accountAPIClient: accountAPIClient,
                                                   context: context,
                                                   workingQueue: workingQueue,
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
    
        public func createRemoteLoginHandler(using login: Login, context: LoginContext?, cryptoEngineProvider: CryptoEngineProvider) async throws -> RemoteLoginHandler {
        let accountInfo = try await accountAPIClient.requestDeviceRegistration(for: login)
        guard let method = accountInfo.loginMethod(for: login, with: context) else {
            throw Error.loginDoesNotExist
        }
        
        let remoteHandler = RemoteLoginHandler(login: login,
                                               deviceRegistrationMethod: method,
                                               deviceInfo: self.deviceInfo,
                                               ssoInfo: accountInfo.ssoInfo,
                                               accountAPIClient: self.accountAPIClient,
                                               sessionsContainer: self.sessionsContainer,
                                               context: context,
                                               workingQueue: self.workingQueue,
                                               logger: self.logger,
                                               cryptoEngineProvider: cryptoEngineProvider)
        return remoteHandler
    }
    
    public func createSession(with configuration: SessionConfiguration, cryptoConfig: CryptoRawConfig, completion: @escaping CompletionBlock<Session, Swift.Error>) {
                self.removeLocalData(configuration.login)
        
        workingQueue.async {
            
            let result =  Result {
                try self.sessionsContainer.createSession(with: configuration, cryptoConfig: cryptoConfig)
            }
            DispatchQueue.main.async {
                completion(result)
            }
        }
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
            let result = try await self.createRemoteLoginHandler(using: login, context: context, cryptoEngineProvider: self.cryptoEngineProvider)
            return LoginResult.remoteLoginRequired(result)
        }
    }
}
