import Foundation
import Combine
import CoreSession
import DashTypes
import CoreKeychain
import CoreSettings
import CoreUserTracking
import CoreNetworking
import UIDelight
import Logger

@MainActor
public class LoginFlowViewModel: ObservableObject, LoginKitServicesInjecting {

    enum Step {
        case login(LoginViewModel)
        case localLogin(LocalLoginFlowViewModel)
        case remoteLogin(RemoteLoginFlowViewModel)
    }

    public enum Completion {
        case localLogin(LocalLoginFlowViewModel.Completion, LocalLoginHandler)
        case remoteLogin(RemoteLoginFlowViewModel.Completion, RemoteLoginHandler)
        case ssoAccountCreation(_ login: Login, SSOLoginInfo)
        case logout
    }

    @Published
    var steps: [Step] = []

    @Published
    var staticErrorPublisher: Error?

    let loginHandler: LoginHandler
    private let installerLogService: InstallerLogServiceProtocol
    let completion: (Completion) -> ()
    let login: Login?
    let deviceId: String?
    private let tokenPublisher: AnyPublisher<String, Never>
    private let localLoginViewModelFactory: LocalLoginFlowViewModel.Factory
    private let remoteLoginViewModelFactory: RemoteLoginFlowViewModel.Factory
    private let loginViewModelFactory: LoginViewModel.Factory
    private let spiegelSettingsManager: LocalSettingsFactory
    private let keychainService: AuthenticationKeychainServiceProtocol
    private let sessionLogger: Logger
    private let versionValidityAlertProvider: AlertContent
    private let purchasePlanFlowProvider: PurchasePlanFlowProvider
    private let sessionActivityReporterProvider: SessionActivityReporterProvider
    private let loginUsageLogService: LoginUsageLogServiceProtocol

    public init(login: Login?,
                deviceId: String?,
                logger: Logger,
                loginHandler: LoginHandler,
                loginUsageLogService: LoginUsageLogServiceProtocol,
                keychainService: AuthenticationKeychainServiceProtocol,
                spiegelSettingsManager: LocalSettingsFactory,
                installerLogService: InstallerLogServiceProtocol,
                localLoginViewModelFactory: LocalLoginFlowViewModel.Factory,
                remoteLoginViewModelFactory: RemoteLoginFlowViewModel.Factory,
                loginViewModelFactory: LoginViewModel.Factory,
                purchasePlanFlowProvider: PurchasePlanFlowProvider,
                sessionActivityReporterProvider: SessionActivityReporterProvider,
                tokenPublisher: AnyPublisher<String, Never>,
                versionValidityAlertProvider: AlertContent,
                completion: @escaping (LoginFlowViewModel.Completion) -> ()) {
        self.deviceId = deviceId
        self.sessionLogger = logger[.session]
        self.tokenPublisher = tokenPublisher
        self.purchasePlanFlowProvider = purchasePlanFlowProvider
        self.sessionActivityReporterProvider = sessionActivityReporterProvider
        self.keychainService = keychainService
        self.loginUsageLogService = loginUsageLogService
        self.loginViewModelFactory = loginViewModelFactory
        self.remoteLoginViewModelFactory = remoteLoginViewModelFactory
        self.localLoginViewModelFactory = localLoginViewModelFactory
        self.loginHandler = loginHandler
        self.spiegelSettingsManager = spiegelSettingsManager
        self.installerLogService = installerLogService
        self.versionValidityAlertProvider = versionValidityAlertProvider
        self.login = login
        self.completion = completion
        createSessionFromSavedLogin()
        installerLogService.login.logShowLogin()
    }

    private func createNewSession() {
        self.steps.append(.login(makeLoginViewModel()))
    }

    private func createSessionFromSavedLogin() {
        guard let login = login else {
            createNewSession()
            return
        }

        Task {
            do {
                try await localLogin(with: login)
            } catch {
                createNewSession()
            }
        }
    }

    private func makeLoginViewModel(email: String? = nil) -> LoginViewModel {
        loginViewModelFactory.make(email: email,
                                   loginHandler: loginHandler,
                                   staticErrorPublisher: self.$staticErrorPublisher.eraseToAnyPublisher(),
                                   versionValidityAlertProvider: versionValidityAlertProvider) { [weak self] result in
            guard let self = self else { return }
            self.connect(using: result)
        }
    }

    func connect(using loginResult: LoginHandler.LoginResult?) {
        guard let result = loginResult else {
            completion(.logout)
            return
        }
        switch result {
        case let .localLoginRequired(localLoginHandler):
            self.steps.append(.localLogin(makeLocalLoginFlowViewModel(using: localLoginHandler)))
        case let .remoteLoginRequired(remoteLoginHandler):
            self.steps.append(.remoteLogin(makeRemoteLoginFlowViewModel(using: remoteLoginHandler)))
        case let .ssoAccountCreation(login, info):
            completion(.ssoAccountCreation(login, info))
        }
    }

    private func localLogin(with login: Login) async throws {
        guard let deviceId = deviceId else {
            fatalError("Device Id Not available")
        }
        loginUsageLogService.markAsLoadingSessionFromSavedLogin()
        let handler = try await loginHandler.createLocalLoginHandler(using: login, deviceId: deviceId, context: LoginContext(origin: .mobile))
        self.steps.append(.login(makeLoginViewModel(email: login.email)))
        self.steps.append(.localLogin(makeLocalLoginFlowViewModel(using: handler)))
    }
}

fileprivate extension LoginFlowViewModel {
    func makeLocalLoginFlowViewModel(using loginHandler: LocalLoginHandler) -> LocalLoginFlowViewModel {
        guard let userSecuritySettings = try? spiegelSettingsManager.fetchOrCreateUserSettings(for: loginHandler.login) else {
            fatalError("Could not get user security settings")
        }

        guard let userSettings = try? spiegelSettingsManager.fetchOrCreateSettings(for: loginHandler.login) else {
            fatalError("Could not get user settings")
        }

        let resetMasterPasswordService = ResetMasterPasswordService(login: loginHandler.login, settings: userSettings, keychainService: keychainService)

        return localLoginViewModelFactory.make(localLoginHandler: loginHandler,
                                               resetMasterPasswordService: resetMasterPasswordService,
                                               userSettings: userSecuritySettings,
                                               email: loginHandler.login.email,
                                               context: .passwordApp) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(completion):
                self.completion(.localLogin(completion, loginHandler))
            case let .failure(error):
                self.handle(error: error)
            }
        }
    }

    func handle(error: Error) {
        switch error {
        case AccountError.invalidOtpBlocked,
            AccountError.rateLimitExceeded:
            self.staticErrorPublisher = error
            self.steps.removeLast()
        default:
            self.sessionLogger.fatal("Failed to load session", error: error)
            self.completion(.logout)
        }
    }

    func makeRemoteLoginFlowViewModel(using loginHandler: RemoteLoginHandler) -> RemoteLoginFlowViewModel {
        remoteLoginViewModelFactory.make(remoteLoginHandler: loginHandler,
                                         email: loginHandler.login.email,
                                         purchasePlanFlowProvider: purchasePlanFlowProvider,
                                         sessionActivityReporterProvider: sessionActivityReporterProvider,
                                         tokenPublisher: tokenPublisher) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(completion):
                self.completion(.remoteLogin(completion, loginHandler))
            case let .failure(error):
                self.handle(error: error)
            }
        }
    }
}
