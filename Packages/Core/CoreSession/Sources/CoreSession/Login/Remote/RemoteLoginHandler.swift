import Foundation
import DashTypes
import SwiftTreats
import DashlaneAPI

public class RemoteLoginHandler {
    public enum Error: Swift.Error, Equatable {
        case wrongMasterKey
        case userDataNotFetched
        case invalidServiceProviderKey
    }

    public enum CompletionType {
        case deviceUnlinking(DeviceUnlinker, session: RemoteLoginSession)
        case completed(Session, isRecoveryLogin: Bool, String?)
        case migrateAccount(AccountMigrationInfos, SSODeviceRegistrationValidator)
    }

    private let logger: Logger
    private let apiclient: AppAPIClient
    private let sessionsContainer: SessionsContainerProtocol
    private let deviceInfo: DeviceInfo
    private let context: LoginContext?
    private let ssoInfo: SSOInfo?
    private let cryptoEngineProvider: CryptoEngineProvider
    var completion: ((CompletionType) -> Void)?

    init(deviceInfo: DeviceInfo,
         ssoInfo: SSOInfo? = nil,
         apiclient: AppAPIClient,
         sessionsContainer: SessionsContainerProtocol,
         context: LoginContext?,
         logger: Logger,
         cryptoEngineProvider: CryptoEngineProvider) {
        self.apiclient = apiclient
        self.sessionsContainer = sessionsContainer
        self.logger = logger
        self.deviceInfo = deviceInfo
        self.context = context
        self.ssoInfo = ssoInfo
        self.cryptoEngineProvider = cryptoEngineProvider
    }

        public func validateMasterKey(_ masterKey: MasterKey,
                                  login: Login,
                                  authTicket: AuthTicket?,
                                  remoteKey: Data? = nil,
                                  using loginDelegate: RemoteLoginDelegate,
                                  data: DeviceRegistrationData,
                                  isRecoveryLogin: Bool,
                                  newMasterPassword: String? = nil,
                                  completion: @escaping CompletionBlock<Void, Swift.Error>) {
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
                                                    remoteKey: remoteKey,
                                                    isRecoveryLogin: isRecoveryLogin,
                                                    newMasterPassword: newMasterPassword)

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

        func requestPairing(using loginDelegate: RemoteLoginDelegate, session: RemoteLoginSession, authTicket: AuthTicket?, completion: @escaping CompletionBlock<Void, Swift.Error>) {
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

        func checkDeviceLimit(using loginDelegate: RemoteLoginDelegate, session: RemoteLoginSession, authTicket: AuthTicket?, completion: @escaping CompletionBlock<Void, Swift.Error>) {
        let unlinker = DeviceUnlinker(session: session,
                                      remoteLoginDelegate: loginDelegate)

        unlinker.refreshLimitAndDevices { result in
            switch result {
                case .success:
                    if unlinker.mode != nil {
                        self.completion?(.deviceUnlinking(unlinker, session: session))
                        completion(.success)
                    } else {
                        Task {
                            do {
                                try await self.load(
                                    session,
                                    using: loginDelegate,
                                    authTicket: authTicket
                                )
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

        @discardableResult
    public func load(
        _ remoteLoginSession: RemoteLoginSession,
        using loginDelegate: RemoteLoginDelegate,
        authTicket: AuthTicket?
    ) async throws -> Session? {
        let loginResponse = try await apiclient
            .authentication
            .getAuthenticationMethodsForLogin(
                login: remoteLoginSession.login.email,
                deviceAccessKey: remoteLoginSession.userData.deviceAccessKey,
                methods: [
                    .emailToken,
                        .totp,
                        .duoPush,
                        .dashlaneAuthenticator
                ],
                profiles: [
                    AuthenticationGetMethodsForLoginProfiles(
                        login: remoteLoginSession.login.email,
                        deviceAccessKey: remoteLoginSession.userData.deviceAccessKey
                    )
                ],
                u2fSecret: nil
            )
        
        let loginOTPOption: ThirdPartyOTPOption? = loginResponse.verifications.loginMethod(
            for: remoteLoginSession.login,
            with: self.context
        )?.otpOption

        let configuration = SessionConfiguration(
            login: remoteLoginSession.login,
            masterKey: remoteLoginSession.masterKey,
            keys: SessionSecureKeys(
                serverAuthentication: remoteLoginSession.authentication,
                remoteKey: remoteLoginSession.remoteKey,
                analyticsIds: remoteLoginSession.userData.analyticsIds
            ),
            info: SessionInfo(
                deviceAccessKey: remoteLoginSession.userData.deviceAccessKey,
                loginOTPOption: loginOTPOption,
                accountType: loginResponse.userAccountType
            )
        )

        let teamSpaceHeader = try? await loginDelegate
            .fetchTeamSpaceCryptoConfigHeader(
                for: remoteLoginSession.login,
                authentication: remoteLoginSession.authentication
            )
        
        var cryptoConfig = remoteLoginSession.cryptoConfig
        if let teamSpaceHeader = teamSpaceHeader {
            cryptoConfig = CryptoRawConfig(
                fixedSalt: cryptoConfig.fixedSalt,
                userParametersHeader: cryptoConfig.parametersHeader,
                teamSpaceParametersHeader: teamSpaceHeader
            )
        }

        return try await self.createSession(with: configuration,
                                            login: remoteLoginSession.login,
                                            cryptoConfig: cryptoConfig,
                                            loginDelegate: loginDelegate,
                                            authTicket: authTicket,
                                            isRecoveryLogin: remoteLoginSession.isRecoveryLogin,
                                            newMasterPassword: remoteLoginSession.newMasterPassword)
    }

        private func createSession(with sessionConfig: SessionConfiguration,
                               login: Login,
                               cryptoConfig: CryptoRawConfig,
                               loginDelegate: RemoteLoginDelegate,
                               authTicket: AuthTicket?,
                               isRecoveryLogin: Bool,
                               newMasterPassword: String?) async throws -> Session? {
        logger.debug("Creating remote session with crypto: \(String(describing: cryptoConfig))")
        let session = try self.sessionsContainer.createSession(
            with: sessionConfig,
            cryptoConfig: cryptoConfig
        )
        
        if let ssoMigration = self.ssoInfo,
           let type = self.ssoInfo?.migration,
           let context = self.context,
           let serviceProviderUrl = URL(string: "\(ssoMigration.serviceProviderUrl)?redirect=\(context.origin.rawValue)&username=\(login.email)&frag=true") {
            let validator = SSODeviceRegistrationValidator(
                login: login,
                serviceProviderUrl: serviceProviderUrl,
                deviceInfo: self.deviceInfo,
                apiClient: apiclient,
                cryptoEngineProvider: self.cryptoEngineProvider,
                isNitroProvider: ssoMigration.isNitroProvider ?? false
            )
            self.completion?(.migrateAccount(
                AccountMigrationInfos(
                    session: session,
                    type: type,
                    authTicket: authTicket),
                validator)
            )
            return nil
        }
        self.completion?(.completed(session, isRecoveryLogin: isRecoveryLogin, newMasterPassword))
        loginDelegate.didCreateSession(session)
        return session
    }
}
