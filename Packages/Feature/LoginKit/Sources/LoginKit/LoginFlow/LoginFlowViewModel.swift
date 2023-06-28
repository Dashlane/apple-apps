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
import SwiftTreats
import CoreLocalization

@MainActor
public class LoginFlowViewModel: ObservableObject, LoginKitServicesInjecting {

    public enum LoginType {
        case localLogin(LocalLoginHandler)
        case remoteLogin(RemoteLoginType)
    }

    public enum RemoteLoginType {
        case classicRemoteLogin(RegularRemoteLoginHandler)
        case deviceToDeviceRemoteLogin(DeviceToDeviceLoginHandler)
    }

    enum Step {
        case loginInput(_ email: String? = nil)
        case login(LoginType)
    }

    public enum Completion {
        case localLogin(LocalLoginFlowViewModel.Completion)
        case remoteLogin(RemoteLoginFlowViewModel.Completion)
        case ssoAccountCreation(_ login: Login, SSOLoginInfo)
        case logout
    }

    @Published
    var steps: [Step] = []

    @Published
    var staticErrorPublisher: Error?

    let loginHandler: LoginHandler
    let completion: (Completion) -> Void
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
    private let loginMetricsReporter: LoginMetricsReporterProtocol
    private let context: LocalLoginFlowContext

    public init(login: Login?,
                deviceId: String?,
                logger: Logger,
                loginHandler: LoginHandler,
                loginMetricsReporter: LoginMetricsReporterProtocol,
                keychainService: AuthenticationKeychainServiceProtocol,
                spiegelSettingsManager: LocalSettingsFactory,
                localLoginViewModelFactory: LocalLoginFlowViewModel.Factory,
                remoteLoginViewModelFactory: RemoteLoginFlowViewModel.Factory,
                loginViewModelFactory: LoginViewModel.Factory,
                purchasePlanFlowProvider: PurchasePlanFlowProvider,
                sessionActivityReporterProvider: SessionActivityReporterProvider,
                tokenPublisher: AnyPublisher<String, Never>,
                versionValidityAlertProvider: AlertContent,
                context: LocalLoginFlowContext,
                completion: @escaping (LoginFlowViewModel.Completion) -> Void) {
        self.deviceId = deviceId
        self.sessionLogger = logger[.session]
        self.tokenPublisher = tokenPublisher
        self.purchasePlanFlowProvider = purchasePlanFlowProvider
        self.sessionActivityReporterProvider = sessionActivityReporterProvider
        self.keychainService = keychainService
        self.loginMetricsReporter = loginMetricsReporter
        self.loginViewModelFactory = loginViewModelFactory
        self.remoteLoginViewModelFactory = remoteLoginViewModelFactory
        self.localLoginViewModelFactory = localLoginViewModelFactory
        self.loginHandler = loginHandler
        self.spiegelSettingsManager = spiegelSettingsManager
        self.versionValidityAlertProvider = versionValidityAlertProvider
        self.login = login
        self.completion = completion
        self.context = context
        createSessionFromSavedLogin()
    }

    private func createNewSession() {
        self.steps.append(.loginInput())
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

    func makeLoginViewModel(email: String? = nil) -> LoginViewModel {
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
            self.steps.append(.login(.localLogin(localLoginHandler)))
        case let .remoteLoginRequired(remoteLoginHandler):
            self.steps.append(.login(.remoteLogin(.classicRemoteLogin(remoteLoginHandler))))
        case let .ssoAccountCreation(login, info):
            completion(.ssoAccountCreation(login, info))
        case let .deviceToDeviceRemoteLogin(deviceToDeviceLoginHandler):
            self.steps.append(.login(.remoteLogin(.deviceToDeviceRemoteLogin(deviceToDeviceLoginHandler))))
        }
    }

    private func localLogin(with login: Login) async throws {
        guard let deviceId = deviceId else {
            fatalError("Device Id Not available")
        }
        loginMetricsReporter.markAsLoadingSessionFromSavedLogin()
        let handler = try await loginHandler.createLocalLoginHandler(using: login, deviceId: deviceId, context: LoginContext(origin: .mobile))
        self.steps.append(.loginInput(login.email))
        self.steps.append(.login(.localLogin(handler)))
    }
}

extension LoginFlowViewModel {
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
                                               context: context) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(completion):
                self.completion(.localLogin(completion))
            case let .failure(error):
                self.handle(error: error)
            }
        }
    }

    func handle(error: Error) {
        switch error {
        case AccountError.invalidOtpBlocked,
            AccountError.rateLimitExceeded:
            self.steps.removeLast()
            self.staticErrorPublisher = error
        default:
            self.sessionLogger.fatal("Failed to load session", error: error)
            if DiagnosticMode.isEnabled {
                self.steps.removeLast()
                self.staticErrorPublisher = error
            } else {
                self.completion(.logout)
            }
        }
    }

    func makeRemoteLoginFlowViewModel(using type: RemoteLoginType) -> RemoteLoginFlowViewModel {
        remoteLoginViewModelFactory.make(type: type, purchasePlanFlowProvider: purchasePlanFlowProvider, sessionActivityReporterProvider: sessionActivityReporterProvider, tokenPublisher: tokenPublisher) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(completion):
                self.completion(.remoteLogin(completion))
            case let .failure(error):
                self.handle(error: error)
            }
        }
    }
}
