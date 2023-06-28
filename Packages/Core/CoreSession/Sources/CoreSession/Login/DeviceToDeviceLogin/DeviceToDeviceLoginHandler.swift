import Foundation
import DashlaneAPI
import DashTypes
import SwiftTreats

public class DeviceToDeviceLoginHandler {

    public enum Error: Swift.Error, Equatable {
        case wrongMasterKey
        case userDataNotFetched
        case invalidServiceProviderKey
        case noToken
    }

        public enum Step {
        case startTransfer
                case verifyLogin(DevciceToDeviceTransferData)
        case pin(DevciceToDeviceTransferData, AuthTicket?)
        case thirdPartyOTP(ThirdPartyOTPDeviceRegistrationValidator)
        case validateMasterKeyAndRegister(DeviceRegistrationData, DevciceToDeviceTransferData, SSOKeys?)
                case deviceUnlinking(DeviceUnlinker, session: RemoteLoginSession)
        case migrateAccount(AccountMigrationInfos, SSODeviceRegistrationValidator)
                case completed(Session, isRecoveryLogin: Bool, String?)
    }

    public let login: Login?
    public let deviceInfo: DeviceInfo
    let apiClient: AppAPIClient
    let context: LoginContext?
    let sessionsContainer: SessionsContainerProtocol
    let logger: Logger
    let cryptoEngineProvider: CryptoEngineProvider
    public let remoteLoginHandler: RemoteLoginHandler

    public internal(set) var step: Step

    public init(login: Login?,
                deviceInfo: DeviceInfo,
                apiClient: AppAPIClient,
                sessionsContainer: SessionsContainerProtocol,
                logger: Logger,
                cryptoEngineProvider: CryptoEngineProvider,
                context: LoginContext?) {
        self.login = login
        self.deviceInfo = deviceInfo
        self.context = context
        self.sessionsContainer = sessionsContainer
        self.logger = logger
        self.cryptoEngineProvider = cryptoEngineProvider
        self.apiClient = apiClient
        self.remoteLoginHandler = RemoteLoginHandler(deviceInfo: deviceInfo, apiclient: apiClient, sessionsContainer: sessionsContainer, context: context, logger: logger, cryptoEngineProvider: cryptoEngineProvider)
        step = .startTransfer
        remoteLoginHandler.completion = { [weak self] result in
            switch result {
            case let .completed(session, isRecoveryLogin, newMasterPassword):
                self?.step = .completed(session, isRecoveryLogin: isRecoveryLogin, newMasterPassword)
            case let .deviceUnlinking(unlinker, session):
                self?.step = .deviceUnlinking(unlinker, session: session)
            case let .migrateAccount(infos, validator):
                self?.step = .migrateAccount(infos, validator)
            }
        }
    }

    public func authTicket(fromToken token: String, login: String) async throws -> AuthTicket {
        let result = try await apiClient.authentication.performExtraDeviceVerification(login: login, token: token)
        return AuthTicket(value: result.authTicket)
    }

    public func registerDevice(with loginData: DevciceToDeviceTransferData, authTicket: AuthTicket?) async throws {
        guard let authTicket = authTicket else {
            let response = try await apiClient.authentication.getAuthenticationMethodsForDevice(login: loginData.login, methods: [.duoPush, .dashlaneAuthenticator, .totp])
            guard let option = response.verifications.loginMethod(for: Login(loginData.login), with: LoginContext(origin: .mobile)),
            let otpOption = option.otpOption else {
                return
            }
            let validator = ThirdPartyOTPDeviceRegistrationValidator(login: Login(loginData.login), deviceInfo: deviceInfo, option: otpOption, apiClient: apiClient) { data in
                self.step = .validateMasterKeyAndRegister(data, loginData, nil)
            }
            self.step = .thirdPartyOTP(validator)
            return
        }

        let deviceRegistrationResponse = try await apiClient.authentication.completeDeviceRegistrationWithAuthTicket(device: deviceInfo, login: loginData.login, authTicket: authTicket.value)
        let registrationData = DeviceRegistrationData(
            initialSettings: deviceRegistrationResponse.settings.content,
            deviceAccessKey: deviceRegistrationResponse.deviceAccessKey,
            deviceSecretKey: deviceRegistrationResponse.deviceSecretKey,
            analyticsIds: AnalyticsIdentifiers(device: deviceRegistrationResponse.deviceAnalyticsId, user: deviceRegistrationResponse.userAnalyticsId),
            serverKey: deviceRegistrationResponse.serverKey,
            remoteKeys: deviceRegistrationResponse.remoteKeys,
            authTicket: authTicket.value)

        switch loginData.key.type {
        case .masterPassword, .invisibleMasterPassword:
            self.step = .validateMasterKeyAndRegister(registrationData, loginData, nil)
        case .sso:
            let ssoKeys = try decipherRemoteKey(ssoKey: loginData.key.value, remoteKey: registrationData.remoteKeys?.ssoRemoteKey(), authTicket: authTicket)
            self.step = .validateMasterKeyAndRegister(registrationData, loginData, ssoKeys)
        }
    }

    func decipherRemoteKey(ssoKey: String,
                           remoteKey: RemoteKey?,
                           authTicket: AuthTicket) throws -> SSOKeys {
        guard let ssoKey = Data(base64Encoded: ssoKey),
              let remoteKey = remoteKey else {
            throw SSOAccountError.userDataNotFetched
        }

        guard let remoteKeyData = Data(base64Encoded: remoteKey.key) else {
            throw SSOAccountError.invalidServiceProviderKey
        }

        let cryptoCenter = try? cryptoEngineProvider.cryptoEngine(for: ssoKey)

        guard let decipheredRemoteKey = cryptoCenter?.decrypt(data: remoteKeyData) else {
            throw SSOAccountError.invalidServiceProviderKey
        }
        return SSOKeys(remoteKey: decipheredRemoteKey, ssoKey: ssoKey, authTicket: authTicket)
    }

    public func verifyLogin(with loginData: DevciceToDeviceTransferData) async throws {
        if loginData.key.accountType == .invisibleMasterPassword, self.login != nil {
            var authTicket: AuthTicket?
            if let token = loginData.token {
                authTicket = try await self.authTicket(fromToken: token, login: loginData.login)
            }
            self.step = .pin(loginData, authTicket)
        } else {
            self.step = .verifyLogin(loginData)
        }
    }

    public func verifiedLogin(for loginData: DevciceToDeviceTransferData) async throws {
        var authTicket: AuthTicket?
        if let token = loginData.token {
            authTicket = try await self.authTicket(fromToken: token, login: loginData.login)
        }
        if loginData.key.accountType == .invisibleMasterPassword {
            self.step = .pin(loginData, authTicket)
        } else {
            try await self.registerDevice(with: loginData, authTicket: authTicket)
        }
    }

        public func validateMasterKey(_ masterKey: MasterKey,
                                  authTicket: AuthTicket?,
                                  remoteKey: Data? = nil,
                                  using loginDelegate: RemoteLoginDelegate,
                                  isRecoveryLogin: Bool,
                                  completion: @escaping CompletionBlock<Void, Swift.Error>) {
        guard case let Step.validateMasterKeyAndRegister(data, loginData, _) = step else {
            completion(.failure(Error.userDataNotFetched))
            return
        }
        remoteLoginHandler.validateMasterKey(masterKey, login: Login(loginData.login), authTicket: authTicket,
                                             remoteKey: remoteKey, using: loginDelegate, data: data, isRecoveryLogin: isRecoveryLogin, completion: completion)
    }

    public func accountRecoveryInfo(for login: Login) async throws -> AccountRecoveryInfo {
        let isEnabled = try await apiClient.accountrecovery.getStatus(login: login.email).enabled
        let accountType = try await apiClient.authentication.getAuthenticationMethodsForDevice(login: login.email, methods: [.emailToken, .dashlaneAuthenticator, .duoPush, .totp]).accountType
        return AccountRecoveryInfo(login: login, isEnabled: isEnabled, accountType: accountType.userAccountType)
    }
}

public extension DeviceToDeviceLoginHandler {
    static var mock: DeviceToDeviceLoginHandler {
        DeviceToDeviceLoginHandler(login: nil, deviceInfo: .mock, apiClient: .fake, sessionsContainer: FakeSessionsContainer(), logger: LoggerMock(), cryptoEngineProvider: FakeCryptoEngineProvider(), context: .init(origin: .mobile))
    }
}

public struct AccountRecoveryInfo: Identifiable {
    public var id: String {
        return login.email
    }
    public let login: Login
    public let isEnabled: Bool
    public let accountType: AccountType

    init(login: Login, isEnabled: Bool, accountType: AccountType) {
        self.login = login
        self.isEnabled = isEnabled
        self.accountType = accountType
    }
}
