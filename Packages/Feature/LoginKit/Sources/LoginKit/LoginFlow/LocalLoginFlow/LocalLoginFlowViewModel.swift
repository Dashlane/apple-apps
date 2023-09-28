import Foundation
import Combine
import CoreSession
import DashTypes
import CoreKeychain
import CoreSettings
import CoreUserTracking
import CoreNetworking
import Logger
import DashlaneAPI

public typealias ServerKey = String

@MainActor
public class LocalLoginFlowViewModel: ObservableObject, LoginKitServicesInjecting {

    public enum Completion {
        public enum MigrationMode {
            case migrateAccount(migrationInfos: AccountMigrationInfos, validator: SSOLocalLoginValidator)
            case migrateSsoKey(type: SSOKeysMigrationType, email: String)
            case migrateAnalyticsId(session: Session)
        }

        case completed(session: Session, shouldResetMP: Bool, shouldRefreshKeychainMasterKey: Bool, loginFlowLogInfo: LoginFlowLogInfo, isRecoveryLogin: Bool, newMasterPassword: String?)
                case migration(MigrationMode, LocalLoginHandler)
        case logout
    }

    enum Step {
        case unlock(viewModel: LocalLoginUnlockViewModel)
        case otp(ThirdPartyOTPOption, hasLock: Bool)
        case sso(SSOLocalLoginValidator)
    }

    @Published
    var steps: [Step] = []

    let email: String

    let localLoginHandler: LocalLoginHandler
    let settingsManager: LocalSettingsFactory
    let keychainService: AuthenticationKeychainServiceProtocol
    let activityReporter: ActivityReporterProtocol
    let loginMetricsReporter: LoginMetricsReporterProtocol
    let nonAuthenticatedUKIBasedWebService: LegacyWebService
    let userSettings: UserSettings
    let resetMasterPasswordService: ResetMasterPasswordServiceProtocol
    let sessionContainer: SessionsContainerProtocol
    let completion: @MainActor (Result<Completion, Error>) -> Void
    let context: LocalLoginFlowContext
    let nitroWebService: NitroAPIClient
    let accountVerificationFlowModelFactory: AccountVerificationFlowModel.Factory
    let recoveryLoginFlowModelFactory: AccountRecoveryKeyLoginFlowModel.Factory
    let localLoginUnlockViewModelFactory: LocalLoginUnlockViewModel.Factory
    let accountType: AccountType
    private let logger: Logger

        var lastSuccessfulAuthenticationMode: Definition.Mode?
        var verificationMode: Definition.VerificationMode = .none
        var isBackupCode: Bool = false

    public init(localLoginHandler: LocalLoginHandler,
                settingsManager: LocalSettingsFactory,
                loginMetricsReporter: LoginMetricsReporterProtocol,
                activityReporter: ActivityReporterProtocol,
                sessionContainer: SessionsContainerProtocol,
                logger: Logger,
                resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
                userSettings: UserSettings,
                nonAuthenticatedUKIBasedWebService: LegacyWebService,
                keychainService: AuthenticationKeychainServiceProtocol,
                email: String,
                context: LocalLoginFlowContext,
                nitroWebService: NitroAPIClient,
                accountVerificationFlowModelFactory: AccountVerificationFlowModel.Factory,
                recoveryLoginFlowModelFactory: AccountRecoveryKeyLoginFlowModel.Factory,
                localLoginUnlockViewModelFactory: LocalLoginUnlockViewModel.Factory,
                completion: @escaping @MainActor (Result<LocalLoginFlowViewModel.Completion, Error>) -> Void) {
        self.localLoginHandler = localLoginHandler
        self.email = email
        self.context = context
        self.userSettings = userSettings
        self.resetMasterPasswordService = resetMasterPasswordService
        self.activityReporter = activityReporter
        self.logger = logger[.session]
        self.sessionContainer = sessionContainer
        self.loginMetricsReporter = loginMetricsReporter
        self.nonAuthenticatedUKIBasedWebService = nonAuthenticatedUKIBasedWebService
        self.completion = completion
        self.keychainService = keychainService
        self.settingsManager = settingsManager
        self.nitroWebService = nitroWebService
        self.accountType = localLoginHandler.accountType
        self.accountVerificationFlowModelFactory = accountVerificationFlowModelFactory
        self.recoveryLoginFlowModelFactory = recoveryLoginFlowModelFactory
        self.localLoginUnlockViewModelFactory = localLoginUnlockViewModelFactory
       updateStep()
    }

    internal func updateStep(for authenticationMode: LocalLoginUnlockViewModel.Completion.AuthenticationMode? = nil) {
        switch localLoginHandler.step {
        case .initialize:
            break
        case let .migrateAccount(migrationInfos, validator):
            completion(.success(.migration(.migrateAccount(migrationInfos: migrationInfos, validator: validator), localLoginHandler)))
        case let .migrateSSOKeys(info):
            completion(.success(.migration(.migrateSsoKey(type: info, email: email), localLoginHandler)))
        case let .migrateAnalyticsId(session):
            completion(.success(.migration(.migrateAnalyticsId(session: session), localLoginHandler)))
        case let .validateThirdPartyOTP(validator):
            Task {
              await validateThirdPartyOTP(with: validator, email: email)
            }
        case let .unlock(handler, unlockType):
            Task {
                await unlock(with: handler, type: unlockType)
            }
        case let .completed(session, isRecoveryLogin):
            var shouldResetMP = false
            if case .resetMasterPassword = authenticationMode {
                shouldResetMP = true
            }
            var newMasterPassword: String?
            if case let .accountRecovered(password) = authenticationMode {
                newMasterPassword = password
            }
            let logInfo = LoginFlowLogInfo(loginMode: lastSuccessfulAuthenticationMode ?? .masterPassword,
                                           verificationMode: verificationMode,
                                           isBackupCode: isBackupCode)
            completion(.success(.completed(session: session,
                                           shouldResetMP: shouldResetMP,
                                           shouldRefreshKeychainMasterKey: shouldRefreshKeychainMasterKey(for: authenticationMode),
                                           loginFlowLogInfo: logInfo,
                                           isRecoveryLogin: isRecoveryLogin,
                                           newMasterPassword: newMasterPassword)))
        }
    }

        private func shouldRefreshKeychainMasterKey(for authenticationMode: LocalLoginUnlockViewModel.Completion.AuthenticationMode?) -> Bool {
        (authenticationMode?.shouldRefreshKeychainMasterKey == true) || (lastSuccessfulAuthenticationMode == .sso)
    }

    private func validateThirdPartyOTP(with option: ThirdPartyOTPOption, email: String) async {
        do {
            guard let serverKey = try serverKey(for: Login(email)) else {
                self.verificationMode = .otp2
                self.steps.append(.otp(option, hasLock: false))
                return
            }
            self.verificationMode = .none
            localLoginHandler.moveToUnlockStep(with: .mpOtp2Validation(authTicket: nil, serverKey: serverKey))
            updateStep()
        } catch {
                        self.verificationMode = .otp2
            self.steps.append(.otp(option, hasLock: true))
        }
    }

    func makeAccountVerificationFlowViewModel(method: VerificationMethod, hasLock: Bool) -> AccountVerificationFlowModel {
        accountVerificationFlowModelFactory.make(login: email, verificationMethod: method, deviceInfo: localLoginHandler.deviceInfo, completion: { [weak self] result in

            guard let self = self else {
                return
            }
            Task {
                do {
                    let (authTicket, _) = try result.get()
                    let serverKey = try await self.localLoginHandler.login(withAuthTicket: authTicket)
                    self.saveServerKey(serverKey, hasLock: hasLock)
                    self.verificationMode = .none
                    self.updateStep()
                } catch {
                    self.completion(.failure(error))
                }
            }
        })
    }

    private func saveServerKey(_ serverKey: String, hasLock: Bool) {
        guard hasLock else {
            return
        }
        try? keychainService.saveServerKey(serverKey, for: Login(email))
    }

    private func serverKey(for login: Login) throws -> ServerKey? {
        guard let settings = try? self.settingsManager.fetchOrCreateSettings(for: localLoginHandler.login) else {
            return nil
        }

        let provider = SecureLockProvider(login: localLoginHandler.login,
                                          settings: settings,
                                          keychainService: keychainService)
        let secureLockMode = provider.secureLockMode()
        guard secureLockMode != .masterKey else {
            return nil
        }
                guard let serverKey = keychainService.serverKey(for: login) else {
            throw KeychainError.itemNotFound
        }
        return serverKey
    }

    private func unlock(with handler: UnlockSessionHandler, type: UnlockType) async {
        guard let settingsStore = try? settingsManager.fetchOrCreateSettings(for: localLoginHandler.login) else {
            assertionFailure("Settings Store should not be nil at this point")
            return
        }

        let provider = SecureLockProvider(login: localLoginHandler.login,
                                          settings: settingsStore,
                                          keychainService: keychainService)
        let secureLockMode = provider.secureLockMode(checkIsBiometricSetIntact: context.shouldCheckBiometricSetIsIntact)

        if shouldStayOnUserLoginScreen() {
            return
        }

        let model = makeLocalLoginUnlockViewModel(secureLockMode: secureLockMode,
                                                  handler: handler,
                                                  unlockType: type,
                                                  accountType: localLoginHandler.accountType,
                                                  context: context)

                let settings = settingsStore.keyed(by: UserSettingsKey.self)

        if !secureLockMode.shouldShowConvenientAuthenticationMethod && type.isSso || settings[.ssoAuthenticationRequested] == true {
            settings[.ssoAuthenticationRequested] = false
            await authenticationUsingSSO(with: handler)
        } else {
            self.steps.append(.unlock(viewModel: model))
        }
    }

            private func shouldStayOnUserLoginScreen() -> Bool {
        guard let settings = try? settingsManager.fetchOrCreateSettings(for: localLoginHandler.login) else {
            return false
        }
        let provider = SecureLockProvider(login: localLoginHandler.login,
                                          settings: settings,
                                          keychainService: keychainService)

        if userSettings[.automaticallyLoggedOut] == true && provider.secureLockMode() == .rememberMasterPassword {
            userSettings[.automaticallyLoggedOut] = false
            return true
        }
        return false
    }

    func authenticationUsingSSO(with handler: UnlockSessionHandler) async {
        activityReporter.report(UserEvent.AskAuthentication(mode: .sso,
                                                            reason: .login,
                                                            verificationMode: Definition.VerificationMode.none))
        guard case let .unlock(_, type) = self.localLoginHandler.step, case let UnlockType.ssoValidation(validator, _, _) = type else {
            assertionFailure()
            return
        }
        self.steps.append(.sso(validator))
    }

    func makeSelfHostedSSOLoginViewModel(with validator: SSOLocalLoginValidator) -> SelfHostedSSOViewModel {
        return SelfHostedSSOViewModel(login: email, authorisationURL: validator.serviceProviderUrl) { result in
            Task {
                await self.handleSSOResult(result, validator: validator)
            }
        }
    }

    func makeNitroSSOLoginViewModel(with validator: SSOLocalLoginValidator) -> NitroSSOLoginViewModel {
        return NitroSSOLoginViewModel(login: email, nitroWebService: nitroWebService) { result in
            Task {
                await self.handleSSOResult(result, validator: validator)
            }
        }
    }

    private func handleSSOResult(_ result: Result<SSOCallbackInfos, Error>, validator: SSOLocalLoginValidator) async {
        do {
            let info = try result.get()
            let ssoKeys = try await validator.validateSSOTokenAndGetKeys(info.ssoToken,
                                                                         serviceProviderKey: info.serviceProviderKey)
            try await self.localLoginHandler.validateSSOKey(ssoKeys, loginContext: LoginContext(origin: .mobile), validator: validator)
            lastSuccessfulAuthenticationMode = .sso
            self.updateStep()
        } catch {
            self.completion(.failure(error))
            self.activityReporter.report(UserEvent.Login(mode: .sso,
                                                         status: .errorInvalidSso,
                                                         verificationMode: Definition.VerificationMode.none))
        }
    }
}

fileprivate extension LocalLoginUnlockViewModel.Completion.AuthenticationMode {
    var shouldRefreshKeychainMasterKey: Bool {
        switch self {
        case .resetMasterPassword, .masterPassword: return true
        default: return false
        }
    }
}

fileprivate extension LocalLoginFlowContext {
        var shouldCheckBiometricSetIsIntact: Bool {
        switch self {
        case .autofillExtension: return false
        default: return true
        }
    }
}
