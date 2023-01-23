import Foundation
import Combine
import CoreSession
import DashTypes
import CoreKeychain
import CoreSettings
import CoreUserTracking
import CoreNetworking

@MainActor
public class RemoteLoginFlowViewModel: ObservableObject, LoginKitServicesInjecting {

    public enum Completion {
        case migrateAccount(migrationInfos: AccountMigrationInfos,
                            validator: SSODeviceRegistrationValidator)
        case completed(session: Session,
                       logInfo: LoginFlowLogInfo)
        case deviceUnlinking(remoteLoginSession: RemoteLoginSession,
                             logInfo: LoginFlowLogInfo,
                             remoteLoginHandler: RemoteLoginHandler,
                             loadActionPublisher: PassthroughSubject<DeviceUnlinkLoadingAction, Never>)
    }

    enum Step {
        case token(TokenViewModel)
        case otp(TOTPRemoteLoginViewModel)
        case authenticatorPush(AuthenticatorPushViewModel)
        case masterPassword(MasterPasswordRemoteViewModel)
        case deviceUnlinking(DeviceUnlinkingFlowViewModel)
        case sso(SSODeviceRegistrationValidator)
    }

    @Published
    var steps: [Step] = []

    let email: String

    let remoteLoginHandler: RemoteLoginHandler
    let settingsManager: LocalSettingsFactory
    let keychainService: AuthenticationKeychainServiceProtocol
    let activityReporter: ActivityReporterProtocol
    let loginUsageLogService: LoginUsageLogServiceProtocol
    let installerLogService: InstallerLogServiceProtocol
    let nonAuthenticatedUKIBasedWebService: LegacyWebService
    let sessionCryptoEngineProvider: SessionCryptoEngineProvider
    let tokenPublisher: AnyPublisher<String, Never>
    let completion: @MainActor (Result<RemoteLoginFlowViewModel.Completion, Error>) -> Void
    let remoteLoginInfoProvider: RemoteLoginDelegate
    let tokenFactory: TokenViewModel.Factory
    let totpFactory: TOTPRemoteLoginViewModel.Factory
    let authenticatorFactory: AuthenticatorPushViewModel.Factory
    let masterPasswordFactory: MasterPasswordRemoteViewModel.Factory
    let deviceUnlinkingFactory: DeviceUnlinkingFlowViewModel.Factory
    let appAPIClient: AppAPIClient
    let purchasePlanFlowProvider: PurchasePlanFlowProvider
    let sessionActivityReporterProvider: SessionActivityReporterProvider
    let nitroWebService: NitroAPIClient
    
        private var lastSuccessfulAuthenticationMode: Definition.Mode?
        var verificationMode: Definition.VerificationMode = .none
        var isBackupCode: Bool = false

    let logger: Logger

    var logInfo: LoginFlowLogInfo {
        .init(loginMode: lastSuccessfulAuthenticationMode ?? .masterPassword,
              verificationMode: verificationMode,
              isBackupCode: isBackupCode)
    }

    public init(remoteLoginHandler: RemoteLoginHandler,
                settingsManager: LocalSettingsFactory,
                loginUsageLogService: LoginUsageLogServiceProtocol,
                installerLogService: InstallerLogServiceProtocol,
                sessionCryptoEngineProvider: SessionCryptoEngineProvider,
                activityReporter: ActivityReporterProtocol,
                remoteLoginInfoProvider: RemoteLoginDelegate,
                logger: Logger,
                nonAuthenticatedUKIBasedWebService: LegacyWebService,
                appAPIClient: AppAPIClient,
                nitroWebService: NitroAPIClient,
                keychainService: AuthenticationKeychainServiceProtocol,
                email: String,
                purchasePlanFlowProvider: PurchasePlanFlowProvider,
                sessionActivityReporterProvider: SessionActivityReporterProvider,
                tokenPublisher: AnyPublisher<String, Never>,
                tokenFactory: TokenViewModel.Factory,
                deviceUnlinkingFactory: DeviceUnlinkingFlowViewModel.Factory,
                totpFactory: TOTPRemoteLoginViewModel.Factory,
                authenticatorFactory: AuthenticatorPushViewModel.Factory,
                masterPasswordFactory: MasterPasswordRemoteViewModel.Factory,
                completion: @escaping @MainActor (Result<RemoteLoginFlowViewModel.Completion, Error>) -> Void) {
        self.remoteLoginHandler = remoteLoginHandler
        self.email = email
        self.purchasePlanFlowProvider = purchasePlanFlowProvider
        self.appAPIClient = appAPIClient
        self.sessionCryptoEngineProvider = sessionCryptoEngineProvider
        self.tokenFactory = tokenFactory
        self.totpFactory = totpFactory
        self.authenticatorFactory = authenticatorFactory
        self.deviceUnlinkingFactory = deviceUnlinkingFactory
        self.sessionActivityReporterProvider = sessionActivityReporterProvider
        self.masterPasswordFactory = masterPasswordFactory
        self.remoteLoginInfoProvider = remoteLoginInfoProvider
        self.activityReporter = activityReporter
        self.logger = logger[.session]
        self.installerLogService = installerLogService
        self.loginUsageLogService = loginUsageLogService
        self.nonAuthenticatedUKIBasedWebService = nonAuthenticatedUKIBasedWebService
        self.completion = completion
        self.keychainService = keychainService
        self.settingsManager = settingsManager
        self.tokenPublisher = tokenPublisher
        self.nitroWebService = nitroWebService
        updateStep()
    }

    internal func updateStep() {
        switch remoteLoginHandler.step {
        case .validateByDeviceRegistrationMethod(let deviceRegistrationValidator):
            switch deviceRegistrationValidator {
            case .tokenByEmail(let validator):
                self.steps.append(.token(makeTokenViewModel(validator: validator)))
            case .thirdPartyOTP(let validator):
                self.steps.append(.otp(self.makeTotpViewModel(validator: validator)))
            case .loginViaSSO(let validator):
                self.steps.append(.sso(validator))
            case .authenticator(let validator):
                self.steps.append(.authenticatorPush(makeAuthenticatorPushViewModel(validator: validator)))
            }
        case .validateMasterPasswordAndRegister(let deviceRegistrationData):
            self.steps.append(.masterPassword(makeMasterPasswordView(loginKeys: LoginKeys(remoteKey: deviceRegistrationData.masterPasswordRemoteKey,
                                                                                          authTicket: deviceRegistrationData.authTicket))))
        case let .deviceUnlinking(deviceUnlinker, session):
            self.steps.append(.deviceUnlinking(makeDeviceUnlinkLoadingViewModel(deviceUnlinker: deviceUnlinker, session: session)))
        case let .migrateAccount(migrationInfos, validator):
            completion(.success(.migrateAccount(migrationInfos: migrationInfos, validator: validator)))
        case .completed(let session):
            self.completion(.success(.completed(session: session, logInfo: logInfo)))
        }
    }
    
    func makeNitroSSOLoginViewModel(with validator: SSODeviceRegistrationValidator) -> NitroSSOLoginViewModel {
       return NitroSSOLoginViewModel(login: email, nitroWebService: nitroWebService) { result in
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
            _ = try await self.validateRemoteKey(ssoKeys)
            self.lastSuccessfulAuthenticationMode = .sso
            self.verificationMode = Definition.VerificationMode.none
            self.installerLogService.login.logSSOSuccess()
            self.updateStep()
        } catch {
            self.installerLogService.sso.log(.failedLoginOnSSOPage)
            self.activityReporter.report(UserEvent.Login(mode: .sso,
                                                         status: .errorInvalidSso,
                                                         verificationMode: Definition.VerificationMode.none))
            self.completion(.failure(error))
        }
    }
}

extension RemoteLoginFlowViewModel {
    private func validateRemoteKey(_ ssoKeys: SSOKeys) async throws -> (Data, String) {
        return try await withCheckedThrowingContinuation { continuation in
            let remoteLoginDelegate = RemoteLoginDelegate(logger: self.logger, cryptoProvider: self.sessionCryptoEngineProvider, appAPIClient: appAPIClient)
            remoteLoginHandler.validateMasterKey(.ssoKey(ssoKeys.ssoKey), authTicket: ssoKeys.authTicket, remoteKey: ssoKeys.remoteKey, using: remoteLoginDelegate) { result in
                continuation.resume(returning: (ssoKeys.remoteKey, ssoKeys.authTicket))
            }
        }
    }
}
