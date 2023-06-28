import Foundation
import Combine
import CoreSession
import DashTypes
import CoreKeychain
import CoreSettings
import CoreUserTracking
import CoreNetworking

@MainActor
public class RegularRemoteLoginFlowViewModel: ObservableObject, LoginKitServicesInjecting {

    public enum Completion {
        case migrateAccount(migrationInfos: AccountMigrationInfos,
                            validator: SSODeviceRegistrationValidator)
        case completed(RemoteLoginConfiguration)
        case deviceUnlinking(DeviceUnlinker,
                             remoteLoginSession: RemoteLoginSession,
                             logInfo: LoginFlowLogInfo,
                             remoteLoginHandler: RemoteLoginHandler)
    }

    public enum Step {
        case verification(VerificationMethod)
        case masterPassword(_ loginKeys: LoginKeys)
        case sso(SSODeviceRegistrationValidator)
    }

    @Published
    var steps: [Step]

    let remoteLoginHandler: RegularRemoteLoginHandler
    let nonAuthenticatedUKIBasedWebService: LegacyWebService
    let tokenPublisher: AnyPublisher<String, Never>
    let masterPasswordFactory: MasterPasswordRemoteViewModel.Factory
    let completion: @MainActor (Result<RegularRemoteLoginFlowViewModel.Completion, Error>) -> Void
    private let email: String
    private let settingsManager: LocalSettingsFactory
    private let keychainService: AuthenticationKeychainServiceProtocol
    private let activityReporter: ActivityReporterProtocol
    private let sessionCryptoEngineProvider: SessionCryptoEngineProvider
    private let remoteLoginInfoProvider: RemoteLoginDelegate
    private let deviceUnlinkingFactory: DeviceUnlinkingFlowViewModel.Factory
    private let appAPIClient: AppAPIClient
    private let sessionActivityReporterProvider: SessionActivityReporterProvider
    private let nitroFactory: NitroSSOLoginViewModel.Factory
    private let accountVerificationFlowModelFactory: AccountVerificationFlowModel.Factory

        private var lastSuccessfulAuthenticationMode: Definition.Mode?
        var verificationMode: Definition.VerificationMode = .none
        var isBackupCode: Bool = false

    let logger: Logger

    var logInfo: LoginFlowLogInfo {
        .init(loginMode: lastSuccessfulAuthenticationMode ?? .masterPassword,
              verificationMode: verificationMode,
              isBackupCode: isBackupCode)
    }

    public init(remoteLoginHandler: RegularRemoteLoginHandler,
                settingsManager: LocalSettingsFactory,
                sessionCryptoEngineProvider: SessionCryptoEngineProvider,
                activityReporter: ActivityReporterProtocol,
                remoteLoginInfoProvider: RemoteLoginDelegate,
                logger: Logger,
                nonAuthenticatedUKIBasedWebService: LegacyWebService,
                appAPIClient: AppAPIClient,
                keychainService: AuthenticationKeychainServiceProtocol,
                email: String,
                sessionActivityReporterProvider: SessionActivityReporterProvider,
                tokenPublisher: AnyPublisher<String, Never>,
                deviceUnlinkingFactory: DeviceUnlinkingFlowViewModel.Factory,
                masterPasswordFactory: MasterPasswordRemoteViewModel.Factory,
                nitroFactory: NitroSSOLoginViewModel.Factory,
                accountVerificationFlowModelFactory: AccountVerificationFlowModel.Factory,
                steps: [RegularRemoteLoginFlowViewModel.Step] = [],
                completion: @escaping @MainActor (Result<RegularRemoteLoginFlowViewModel.Completion, Error>) -> Void) {
        self.remoteLoginHandler = remoteLoginHandler
        self.email = email
        self.appAPIClient = appAPIClient
        self.sessionCryptoEngineProvider = sessionCryptoEngineProvider
        self.deviceUnlinkingFactory = deviceUnlinkingFactory
        self.sessionActivityReporterProvider = sessionActivityReporterProvider
        self.masterPasswordFactory = masterPasswordFactory
        self.nitroFactory = nitroFactory
        self.remoteLoginInfoProvider = remoteLoginInfoProvider
        self.activityReporter = activityReporter
        self.logger = logger[.session]
        self.nonAuthenticatedUKIBasedWebService = nonAuthenticatedUKIBasedWebService
        self.completion = completion
        self.keychainService = keychainService
        self.settingsManager = settingsManager
        self.tokenPublisher = tokenPublisher
        self.steps = steps
        self.accountVerificationFlowModelFactory = accountVerificationFlowModelFactory
        updateStep()
    }

    internal func updateStep() {
        switch remoteLoginHandler.step {
        case .validateByDeviceRegistrationMethod(let deviceRegistrationValidator):
            switch deviceRegistrationValidator {
            case .tokenByEmail:
                self.steps.append(.verification(.emailToken))
            case .thirdPartyOTP(let option):
                self.steps.append(.verification(.totp(option.pushType)))
            case .loginViaSSO(let validator):
                self.steps.append(.sso(validator))
            case .authenticator:
                self.steps.append(.verification(.authenticatorPush))
            }
        case .validateMasterPasswordAndRegister(let deviceRegistrationData):
            self.steps.append(.masterPassword(LoginKeys(remoteKey: deviceRegistrationData.masterPasswordRemoteKey,
                                                                                               authTicket: deviceRegistrationData.authTicket)))
        case let .deviceUnlinking(deviceUnlinker, session):
            self.completion(.success(.deviceUnlinking(deviceUnlinker, remoteLoginSession: session, logInfo: self.logInfo, remoteLoginHandler: self.remoteLoginHandler.remoteLoginHandler)))
        case let .migrateAccount(migrationInfos, validator):
            self.completion(.success(.migrateAccount(migrationInfos: migrationInfos, validator: validator)))
        case let .completed(session, isRecoveryLogin, newMasterPassword):
            self.completion(.success(.completed(RemoteLoginConfiguration(session: session, logInfo: self.logInfo, isRecoveryLogin: isRecoveryLogin, newMasterPassword: newMasterPassword))))
        }
    }

    func makeAccountVerificationFlowViewModel(method: VerificationMethod) -> AccountVerificationFlowModel {
        accountVerificationFlowModelFactory.make(login: email, verificationMethod: method, deviceInfo: remoteLoginHandler.deviceInfo, debugTokenPublisher: tokenPublisher, completion: { [weak self] completion in

            guard let self = self else {
                return
            }
            Task {
                do {
                    let (authTicket, isBackupCode) = try completion.get()
                    try await self.remoteLoginHandler.registerDevice(withAuthTicket: authTicket)
                    self.verificationMode = .otp1
                    self.isBackupCode = isBackupCode
                    self.updateStep()
                } catch {
                    self.completion(.failure(error))
                }
            }
        })
    }

    func makeNitroSSOLoginViewModel(with validator: SSODeviceRegistrationValidator) -> NitroSSOLoginViewModel {
        return nitroFactory.make(login: email) { result in
            Task { @MainActor in
                await self.handleSSOResult(result, validator: validator)
            }
        }
    }

    func makeSelfHostedSSOLoginViewModel(with validator: SSODeviceRegistrationValidator) -> SelfHostedSSOViewModel {
        return SelfHostedSSOViewModel(login: email, authorisationURL: validator.serviceProviderUrl) { result in
            Task { @MainActor in
                await self.handleSSOResult(result, validator: validator)
            }
        }
    }

    private func handleSSOResult(_ result: Result<SSOCallbackInfos, Error>, validator: SSODeviceRegistrationValidator) async {
        lastSuccessfulAuthenticationMode = .sso
        verificationMode = .none
        do {
            let info = try result.get()
            let ssoKeys = try await validator.validateSSOTokenAndGetKeys(info.ssoToken,
                                                                         serviceProviderKey: info.serviceProviderKey)
            _ = try await self.validateRemoteKey(ssoKeys, isRecoveryLogin: false)
            self.lastSuccessfulAuthenticationMode = .sso
            self.verificationMode = Definition.VerificationMode.none
            self.updateStep()
        } catch {
            self.activityReporter.report(UserEvent.Login(mode: .sso,
                                                         status: .errorInvalidSso,
                                                         verificationMode: Definition.VerificationMode.none))
            self.completion(.failure(error))
        }
    }
}

extension RegularRemoteLoginFlowViewModel {
    private func validateRemoteKey(_ ssoKeys: SSOKeys, isRecoveryLogin: Bool) async throws -> (Data, AuthTicket) {
        return try await withCheckedThrowingContinuation { continuation in
            let remoteLoginDelegate = RemoteLoginDelegate(logger: self.logger, cryptoProvider: self.sessionCryptoEngineProvider, appAPIClient: self.appAPIClient)
            remoteLoginHandler.validateMasterKey(.ssoKey(ssoKeys.ssoKey), authTicket: ssoKeys.authTicket, remoteKey: ssoKeys.remoteKey, using: remoteLoginDelegate, isRecoveryLogin: isRecoveryLogin) { _ in
                continuation.resume(returning: (ssoKeys.remoteKey, ssoKeys.authTicket))
            }
        }
    }

        static func mock() -> RegularRemoteLoginFlowViewModel {
        return RegularRemoteLoginFlowViewModel(
            remoteLoginHandler: RegularRemoteLoginHandler.mock,
            settingsManager: LocalSettingsFactoryMock.mock,
            sessionCryptoEngineProvider: SessionCryptoEngineProvider(logger: LoggerMock()),
            activityReporter: FakeActivityReporter(),
            remoteLoginInfoProvider: RemoteLoginDelegate.mock,
            logger: LoggerMock(),
            nonAuthenticatedUKIBasedWebService: LegacyWebServiceMock(response: ""),
            appAPIClient: .fake,
            keychainService: FakeAuthenticationKeychainService.mock,
            email: "",
            sessionActivityReporterProvider: FakeSessionActivityReporter(),
            tokenPublisher: PassthroughSubject().eraseToAnyPublisher(),
            deviceUnlinkingFactory: InjectedFactory { deviceUnlinker, login, _, purchasePlanFlowProvider, _, completion in
                DeviceUnlinkingFlowViewModel(
                    deviceUnlinker: deviceUnlinker,
                    login: login,
                    authentication: ServerAuthentication(deviceAccessKey: "", deviceSecretKey: ""),
                    logger: LoggerMock(),
                    purchasePlanFlowProvider: purchasePlanFlowProvider,
                    userTrackingSessionActivityReporter: FakeActivityReporter(),
                    completion: completion
                )
            },
            masterPasswordFactory: InjectedFactory {_, _, _, _, _, _, _ in
                return .mock
            },
            nitroFactory: InjectedFactory { login, completion in
                NitroSSOLoginViewModel(login: login, nitroWebService: .mock, completion: completion)
            },
            accountVerificationFlowModelFactory: .init { _, _, _, _, _ in
                AccountVerificationFlowModel.mock(verificationMethod: .emailToken)
            },
            steps: [.verification(.authenticatorPush)]
        ) { _ in }
    }
}
