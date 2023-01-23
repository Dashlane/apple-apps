import Foundation
import Combine
import CoreSession
import DashTypes
import CoreKeychain
import CoreSettings
import CoreUserTracking
import CoreNetworking
import Logger

@MainActor
public class LocalLoginFlowViewModel: ObservableObject, LoginKitServicesInjecting {

    public enum Completion {
        public enum MigrationMode {
            case migrateAccount(migrationInfos: AccountMigrationInfos, validator: SSOLocalLoginValidator)
            case migrateSsoKey(type: SSOKeysMigrationType, email: String)
            case migrateAnalyticsId(session: Session)
        }

        case completed(session: Session, shouldResetMP: Bool, shouldRefreshKeychainMasterKey: Bool, loginFlowLogInfo: LoginFlowLogInfo)
        case migration(MigrationMode)
        case logout
    }

    enum Step {
        case unlock(viewModel: LocalLoginUnlockViewModel)
        case otp(validator: ThirdPartyOTPLocalLoginValidator, hasLock: Bool)
        case sso(SSOLocalLoginValidator)
    }

    @Published
    var steps: [Step] = []
    
    let email: String

    let localLoginHandler: LocalLoginHandler
    let settingsManager: LocalSettingsFactory
    let keychainService: AuthenticationKeychainServiceProtocol
    let activityReporter: ActivityReporterProtocol
    let loginUsageLogService: LoginUsageLogServiceProtocol
    let installerLogService: InstallerLogServiceProtocol
    let nonAuthenticatedUKIBasedWebService: LegacyWebService
    let userSettings: UserSettings
    let resetMasterPasswordService: ResetMasterPasswordServiceProtocol
    let sessionContainer: SessionsContainerProtocol
    let completion: @MainActor (Result<Completion, Error>) -> Void
    let context: LocalLoginFlowContext
    let nitroWebService: NitroAPIClient
    
    private let logger: Logger

    var isPartOfSSOCompany: Bool {
        (try? sessionContainer.info(for: localLoginHandler.login).isPartOfSSOCompany == true) ?? false
    }

        var lastSuccessfulAuthenticationMode: Definition.Mode?
        var verificationMode: Definition.VerificationMode = .none
        var isBackupCode: Bool = false

    public init(localLoginHandler: LocalLoginHandler,
                settingsManager: LocalSettingsFactory,
                loginUsageLogService: LoginUsageLogServiceProtocol,
                installerLogService: InstallerLogServiceProtocol,
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
                completion: @escaping @MainActor (Result<LocalLoginFlowViewModel.Completion, Error>) -> Void) {
        self.localLoginHandler = localLoginHandler
        self.email = email
        self.context = context
        self.userSettings = userSettings
        self.resetMasterPasswordService = resetMasterPasswordService
        self.activityReporter = activityReporter
        self.logger = logger[.session]
        self.installerLogService = installerLogService
        self.sessionContainer = sessionContainer
        self.loginUsageLogService = loginUsageLogService
        self.nonAuthenticatedUKIBasedWebService = nonAuthenticatedUKIBasedWebService
        self.completion = completion
        self.keychainService = keychainService
        self.settingsManager = settingsManager
        self.nitroWebService = nitroWebService
        updateStep()
    }

    internal func updateStep(for authenticationMode: LocalLoginUnlockViewModel.Completion.AuthenticationMode? = nil) {
        switch localLoginHandler.step {
        case .initialize:
            break
        case let .migrateAccount(migrationInfos, validator):
            completion(.success(.migration(.migrateAccount(migrationInfos: migrationInfos, validator: validator))))
        case let .migrateSSOKeys(info):
            completion(.success(.migration(.migrateSsoKey(type: info, email: email))))
        case let .migrateAnalyticsId(session):
            completion(.success(.migration(.migrateAnalyticsId(session: session))))
        case let .validateThirdPartyOTP(validator):
            Task {
              await validateThirdPartyOTP(with: validator, email: email)
            }
        case let .unlock(handler, unlockType):
            Task {
                await unlock(with: handler, type: unlockType)
            }
        case let .completed(session):
            let shouldResetMP = authenticationMode == .resetMasterPassword
            let logInfo = LoginFlowLogInfo(loginMode: lastSuccessfulAuthenticationMode ?? .masterPassword,
                                           verificationMode: verificationMode,
                                           isBackupCode: isBackupCode)
            completion(.success(.completed(session: session,
                                           shouldResetMP: shouldResetMP,
                                           shouldRefreshKeychainMasterKey: shouldRefreshKeychainMasterKey(for: authenticationMode),
                                           loginFlowLogInfo: logInfo)))
        }
    }

        private func shouldRefreshKeychainMasterKey(for authenticationMode: LocalLoginUnlockViewModel.Completion.AuthenticationMode?) -> Bool {
        (authenticationMode?.shouldRefreshKeychainMasterKey == true) || (lastSuccessfulAuthenticationMode == .sso)
    }

    private func validateThirdPartyOTP(with validator: ThirdPartyOTPLocalLoginValidator, email: String) async {
        do {
            guard let serverKey = try serverKey(for: Login(email)) else {
                self.verificationMode = .otp2
                self.steps.append(.otp(validator: validator, hasLock: false))
                return
            }
            self.verificationMode = .none
            await localLoginHandler.thirdPartyOTPLocalLoginValidatorDidRetrieveServerKey(serverKey, authTicket: nil)
            updateStep()
        } catch {
                        self.verificationMode = .otp2
            self.steps.append(.otp(validator: validator, hasLock: true))
        }
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
                                                  context: context)
        self.steps.append(.unlock(viewModel: model))

                let settings = settingsStore.keyed(by: UserSettingsKey.self)
        if isPartOfSSOCompany && settings[.ssoAuthenticationRequested] == true {
            settings[.ssoAuthenticationRequested] = false
            await authenticationUsingSSO(with: handler)
            return
        }

        if !secureLockMode.shouldShowConvenientAuthenticationMethod && type.isSso {
            await authenticationUsingSSO(with: handler)
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
            self.installerLogService.login.logSSOSuccess()
            lastSuccessfulAuthenticationMode = .sso
            self.updateStep()
        } catch {
            self.completion(.failure(error))
            self.activityReporter.report(UserEvent.Login(mode: .sso,
                                                         status: .errorInvalidSso,
                                                         verificationMode: Definition.VerificationMode.none))
            self.installerLogService.login.logSSOFailure()
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
