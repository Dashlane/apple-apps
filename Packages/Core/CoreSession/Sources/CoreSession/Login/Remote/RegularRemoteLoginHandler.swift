import Foundation
import DashTypes
import SwiftTreats
import DashlaneAPI

public class RegularRemoteLoginHandler {
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
                case completed(Session, isRecoveryLogin: Bool, String?)
    }

    private let logger: Logger
    public let login: Login
    public internal(set) var step: Step
    private let sessionsContainer: SessionsContainerProtocol
    public let deviceInfo: DeviceInfo
    public let deviceRegistrationMethod: LoginMethod
    private let context: LoginContext?
    private let ssoInfo: SSOInfo?
    private let cryptoEngineProvider: CryptoEngineProvider
    public let remoteLoginHandler: RemoteLoginHandler
    private let appAPIClient: AppAPIClient

    init(login: Login,
         deviceRegistrationMethod: LoginMethod,
         deviceInfo: DeviceInfo,
         ssoInfo: SSOInfo? = nil,
         appAPIClient: AppAPIClient,
         sessionsContainer: SessionsContainerProtocol,
         context: LoginContext?,
         logger: Logger,
         cryptoEngineProvider: CryptoEngineProvider) {
        self.login = login
        self.sessionsContainer = sessionsContainer
        self.logger = logger
        self.deviceInfo = deviceInfo
        self.deviceRegistrationMethod = deviceRegistrationMethod
        self.context = context
        self.ssoInfo = ssoInfo
        self.appAPIClient = appAPIClient
        self.cryptoEngineProvider = cryptoEngineProvider
        self.remoteLoginHandler = RemoteLoginHandler(deviceInfo: deviceInfo, ssoInfo: ssoInfo, apiclient: appAPIClient, sessionsContainer: sessionsContainer, context: context, logger: logger, cryptoEngineProvider: cryptoEngineProvider)
        let validatorEnum: DeviceRegistrationValidatorEnumeration

        switch deviceRegistrationMethod {
        case .tokenByEmail:
            validatorEnum = .tokenByEmail
        case let .thirdPartyOTP(option, _):
            validatorEnum = .thirdPartyOTP(option)
        case let .loginViaSSO(serviceProviderUrl, isNitroProvider):
            validatorEnum = .loginViaSSO(SSODeviceRegistrationValidator(login: login, serviceProviderUrl: serviceProviderUrl, deviceInfo: deviceInfo, apiClient: appAPIClient, cryptoEngineProvider: cryptoEngineProvider, isNitroProvider: isNitroProvider))

        case .authenticator:
            validatorEnum = .authenticator
        }

        step = .validateByDeviceRegistrationMethod(validatorEnum)
        validatorEnum.validator?.deviceRegistrationValidatorDidFetch = { [weak self] remoteAuthenticationData in
            guard let self = self else {
                return
            }
            self.step = .validateMasterPasswordAndRegister(remoteAuthenticationData)
        }
        remoteLoginHandler.completion = { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case let .completed(session, isRecoveryLogin, newMasterPassword):
                self.step = .completed(session, isRecoveryLogin: isRecoveryLogin, newMasterPassword)
            case let .deviceUnlinking(unlinker, session):
                self.step = .deviceUnlinking(unlinker, session: session)
            case let .migrateAccount(infos, validator):
                self.step = .migrateAccount(infos, validator)
            }
        }
    }

    public func validateMasterKey(_ masterKey: MasterKey,
                                  authTicket: AuthTicket?,
                                  remoteKey: Data? = nil,
                                  using loginDelegate: RemoteLoginDelegate,
                                  isRecoveryLogin: Bool = false,
                                  newMasterPassword: String? = nil,
                                  completion: @escaping CompletionBlock<Void, Swift.Error>) {

        guard case let Step.validateMasterPasswordAndRegister(data) = step else {
            completion(.failure(Error.userDataNotFetched))
            return
        }
        remoteLoginHandler.validateMasterKey(masterKey, login: login, authTicket: authTicket, remoteKey: remoteKey, using: loginDelegate, data: data, isRecoveryLogin: isRecoveryLogin, newMasterPassword: newMasterPassword, completion: completion)

    }

    public func registerDevice(withAuthTicket authTicket: AuthTicket) async throws {
        let deviceRegistrationResponse = try await appAPIClient.authentication.completeDeviceRegistrationWithAuthTicket(device: deviceInfo, login: login.email, authTicket: authTicket.value)
        let deviceRegistrationData = DeviceRegistrationData(
            initialSettings: deviceRegistrationResponse.settings.content,
            deviceAccessKey: deviceRegistrationResponse.deviceAccessKey,
            deviceSecretKey: deviceRegistrationResponse.deviceSecretKey,
            analyticsIds: deviceRegistrationResponse.analyticsIds,
            serverKey: deviceRegistrationResponse.serverKey,
            remoteKeys: deviceRegistrationResponse.remoteKeys,
            authTicket: authTicket.value)
        self.step = .validateMasterPasswordAndRegister(deviceRegistrationData)
    }
}

extension RegularRemoteLoginHandler {
    public static var mock: RegularRemoteLoginHandler {
        return RegularRemoteLoginHandler(
            login: Login("_"),
            deviceRegistrationMethod: .authenticator,
            deviceInfo: .mock,
            appAPIClient: .fake,
            sessionsContainer: SessionsContainer<InMemorySessionStoreProvider>.mock,
            context: .init(origin: .mobile),
            logger: LoggerMock(),
            cryptoEngineProvider: FakeCryptoEngineProvider()
        )
    }
}
