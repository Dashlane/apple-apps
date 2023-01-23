import Foundation
import DashTypes
import SwiftTreats

public class RemoteLoginHandler {
    public enum Error: Swift.Error, Equatable {
        case wrongMasterKey
        case userDataNotFetched
        case invalidServiceProviderKey
    }

        public enum Step {
                case validateByDeviceRegistrationMethod(DeviceRegistrationValidatorEnumeration)
                case validateMasterPasswordAndRegister(DeviceRegistrationData)
                case deviceUnlinking(DeviceUnlinker, session: RemoteLoginSession)
                case migrateAccount(AccountMigrationInfos, SSODeviceRegistrationValidator)
                case completed(Session)
    }

    private let logger: Logger
    public let login: Login
    public internal(set) var step: Step
    private let accountAPIClient: AccountAPIClientProtocol
    private let sessionsContainer: SessionsContainerProtocol
    private let deviceInfo: DeviceInfo
    public let deviceRegistrationMethod: LoginMethod
    private let context: LoginContext?
    private let ssoInfo: SSOInfo?
    private let workingQueue: DispatchQueue
    private let cryptoEngineProvider: CryptoEngineProvider
    
    init(login: Login,
         deviceRegistrationMethod: LoginMethod,
         deviceInfo: DeviceInfo,
         ssoInfo: SSOInfo? = nil,
         accountAPIClient: AccountAPIClientProtocol,
         sessionsContainer: SessionsContainerProtocol,
         context: LoginContext?,
         workingQueue: DispatchQueue,
         logger: Logger,
         cryptoEngineProvider: CryptoEngineProvider) {
        self.login = login
        self.accountAPIClient = accountAPIClient
        self.sessionsContainer = sessionsContainer
        self.logger = logger
        self.deviceInfo = deviceInfo
        self.deviceRegistrationMethod = deviceRegistrationMethod
        self.context = context
        self.ssoInfo = ssoInfo
        self.workingQueue = workingQueue
        self.cryptoEngineProvider = cryptoEngineProvider
        let validatorEnum: DeviceRegistrationValidatorEnumeration

        switch deviceRegistrationMethod {
        case .tokenByEmail:
            validatorEnum = .tokenByEmail(TokenDeviceRegistrationValidator(login: login, deviceInfo: deviceInfo, accountAPIClient: accountAPIClient))
        case let .thirdPartyOTP(option, _):
            validatorEnum = .thirdPartyOTP(ThirdPartyOTPDeviceRegistrationValidator(login: login, deviceInfo: deviceInfo, option: option, accountAPIClient: accountAPIClient))
        case let .loginViaSSO(serviceProviderUrl, isNitroProvider):
            validatorEnum = .loginViaSSO(SSODeviceRegistrationValidator(login: login, serviceProviderUrl: serviceProviderUrl, deviceInfo: deviceInfo, accountAPIClient: accountAPIClient, cryptoEngineProvider: cryptoEngineProvider, isNitroProvider: isNitroProvider))
            
        case .authenticator:
            validatorEnum = .authenticator(TokenDeviceRegistrationValidator(login: login, deviceInfo: deviceInfo, accountAPIClient: accountAPIClient))
        }

        step = .validateByDeviceRegistrationMethod(validatorEnum)
        validatorEnum.validator.delegate = self
    }

        public func validateMasterKey(_ masterKey: MasterKey,
                                  authTicket: String?,
                                  remoteKey: Data? = nil,
                                  using loginDelegate: RemoteLoginDelegate,
                                  completion: @escaping CompletionBlock<Void, Swift.Error>) {
        guard case let Step.validateMasterPasswordAndRegister(data) = step else {
            completion(.failure(Error.userDataNotFetched))
            return
        }
        let masterKey = masterKey.masterKey(withServerKey: data.serverKey)
        guard let cryptoConfig = try? loginDelegate.retrieveCryptoConfig(fromEncryptedSettings: data.initialSettings, using: masterKey, remoteKey: remoteKey) else {
            completion(.failure(Error.wrongMasterKey))
            return
        }

        
        let authentication = ServerAuthentication(deviceAccessKey: data.deviceAccessKey, deviceSecretKey: data.deviceSecretKey)

        let remoteLoginSession = RemoteLoginSession(login: login,
                                                    userData: data,
                                                    cryptoConfig: cryptoConfig,
                                                    masterKey: masterKey,
                                                    authentication: authentication,
                                                    remoteKey: remoteKey)

        #if targetEnvironment(macCatalyst)
        requestPairing(using: loginDelegate,
                       session: remoteLoginSession,
                       authTicket: data.authTicket,
                       completion: completion)
        #else
        checkDeviceLimit(using: loginDelegate,
                         session: remoteLoginSession,
                         authTicket: data.authTicket,
                         completion: completion)
        #endif
      
    }

        func requestPairing(using loginDelegate: RemoteLoginDelegate, session: RemoteLoginSession, authTicket: String?, completion: @escaping CompletionBlock<Void, Swift.Error>) {
        let deviceService = loginDelegate.deviceService(for: session.login, authentication: session.authentication)
        
        deviceService.requestPairingGroup { result in
            switch result {
                case .success:
                    self.checkDeviceLimit(using: loginDelegate,
                                          session: session,
                                          authTicket: authTicket,
                                          completion: completion)
                case let .failure( error):
                    completion(.failure(error))
            }
        }
    }
    
        func checkDeviceLimit(using loginDelegate: RemoteLoginDelegate, session: RemoteLoginSession, authTicket: String?, completion: @escaping CompletionBlock<Void, Swift.Error>) {
        let unlinker = DeviceUnlinker(session: session,
                                      remoteLoginDelegate: loginDelegate)

        unlinker.refreshLimitAndDevices { result in
            switch result {
                case .success:
                    if unlinker.mode != nil {
                        self.step = .deviceUnlinking(unlinker, session: session)
                        completion(.success)
                    } else {
                        Task {
                            do {
                              try await self.load(session,
                                                  using: loginDelegate,
                                                  authTicket: authTicket)
                                await MainActor.run {
                                    completion(.success)
                                }
                            } catch {
                                await MainActor.run {
                                    completion(.failure(error))
                                }
                            }
                        }
                       
                    }
                case let .failure( error):
                    completion(.failure(error))
            }
        }
    }

        public func load(_ remoteLoginSession: RemoteLoginSession,
                     using loginDelegate: RemoteLoginDelegate,
                     authTicket: String?) async throws {
        let loginResponse = try await accountAPIClient.requestLogin(with: LoginRequestInfo(login: login.email,
                                                                                            deviceAccessKey: remoteLoginSession.userData.deviceAccessKey,
                                                                                            u2fSecret: nil,
                                                                                            loginsToCheckForDeletion: [login]))
        let loginOTPOption: ThirdPartyOTPOption? = loginResponse.loginOTPOption(for: self.login, with: self.context)
        
        let isPartOfSSOCompany: Bool = loginResponse.isPartOfSSOCompany(for: self.login, with: self.context)
        
        let configuration = SessionConfiguration(login: self.login,
                                                 masterKey: remoteLoginSession.masterKey,
                                                 keys: SessionSecureKeys(serverAuthentication: remoteLoginSession.authentication,
                                                                         remoteKey: remoteLoginSession.remoteKey,
                                                                         analyticsIds: remoteLoginSession.userData.analyticsIds),
                                                 info: SessionInfo(deviceAccessKey: remoteLoginSession.userData.deviceAccessKey,
                                                                   loginOTPOption: loginOTPOption,
                                                                   isPartOfSSOCompany: isPartOfSSOCompany))
        
        let teamSpaceHeader = try? await loginDelegate.fetchTeamSpaceCryptoConfigHeader(for: self.login, authentication: remoteLoginSession.authentication)
        var cryptoConfig = remoteLoginSession.cryptoConfig
        if let teamSpaceHeader = teamSpaceHeader {
            cryptoConfig = CryptoRawConfig(fixedSalt: cryptoConfig.fixedSalt,
                                           userParametersHeader: cryptoConfig.parametersHeader,
                                           teamSpaceParametersHeader: teamSpaceHeader)
        }
        
        try await self.createSession(with: configuration,
                                     cryptoConfig: cryptoConfig,
                                     loginDelegate: loginDelegate,
                                     authTicket: authTicket)
    }
                                                           
        private func createSession(with sessionConfig: SessionConfiguration,
                               cryptoConfig: CryptoRawConfig,
                               loginDelegate: RemoteLoginDelegate,
                               authTicket: String?) async throws {
        logger.debug("Creating remote session with crypto: \(String(describing: cryptoConfig))")
        let session = try self.sessionsContainer.createSession(with: sessionConfig, cryptoConfig: cryptoConfig)
        if let ssoMigration = self.ssoInfo,
           let type = self.ssoInfo?.migration,
           let context = self.context,
           let serviceProviderUrl = URL(string: "\(ssoMigration.serviceProviderUrl)?redirect=\(context.origin.rawValue)&username=\(self.login.email)&frag=true") {
            let validator = SSODeviceRegistrationValidator(login: self.login,
                                                           serviceProviderUrl: serviceProviderUrl,
                                                           deviceInfo: self.deviceInfo,
                                                           accountAPIClient: self.accountAPIClient,
                                                           cryptoEngineProvider: self.cryptoEngineProvider,
                                                           isNitroProvider: ssoMigration.isNitroProvider ?? false)
            self.step = .migrateAccount(AccountMigrationInfos(session: session,
                                                              type: type,
                                                              authTicket: authTicket),
                                        validator)
            return
        }
        self.step = .completed(session)
        loginDelegate.didCreateSession(session)

    }
}
                                                           
extension RemoteLoginHandler: DeviceRegistrationValidatorDelegate {
    public func deviceRegistrationValidatorDidFetch(_ remoteAuthenticationData: DeviceRegistrationData) {
        step = .validateMasterPasswordAndRegister(remoteAuthenticationData)
    }
}
