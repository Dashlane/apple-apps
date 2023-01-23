import UIKit
import CoreSession
import SwiftUI
import Combine
import DashTypes
import Logger
import DashlaneAppKit
import LoginKit
import CoreUserTracking

@MainActor
class LoginCoordinator: Coordinator {

    enum LoginCompletionType {
        case servicesLoaded(SessionServicesContainer)
        case ssoAccountCreation(_ login: Login, SSOLoginInfo)
        case logout
    }

    let navigator: Navigator
    let loginHandler: LoginHandler
    let appServices: AppServicesContainer
    let completion: (LoginCompletionType) -> Void
    var currentSubCoordinator: Coordinator?
    let sessionLogger: Logger
    let login: Login?
    let loginKitServices: LoginKitServicesContainer

    @Published
    var staticErrorPublisher: Error?
    var sessionServicesSubscription: AnyCancellable?

    init(loginHandler: LoginHandler,
         appServices: AppServicesContainer,
         sessionLogger: Logger,
         navigator: Navigator,
         login: Login?,
         completion: @escaping (LoginCompletionType) -> Void) {
        self.navigator = navigator
        self.loginHandler = loginHandler
        self.completion = completion
        self.appServices = appServices
        self.sessionLogger = sessionLogger
        self.login = login

        loginKitServices = appServices.makeLoginKitServicesContainer(logger: appServices.installerLogService.login)
    }

    func start() {
        let viewModel = loginKitServices.makeLoginFlowViewModel(
            login: login,
            deviceId: appServices.globalSettings.deviceId,
            loginHandler: loginHandler,
            purchasePlanFlowProvider: PurchasePlanFlowProvider(appServices: appServices),
            sessionActivityReporterProvider: SessionActivityProvider(appActivityReporter: appServices.activityReporter),
            tokenPublisher: appServices.deepLinkingService.tokenPublisher(),
            versionValidityAlertProvider: VersionValidityAlert.errorAlert()) { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .logout:
                    self.completion(.logout)
                case let .localLogin(completion, localLoginHandler):
                    self.handleLocalLoginCompletion(completion, localLoginHandler: localLoginHandler)
                case let .remoteLogin(completion, remoteLoginHandler):
                    self.handleRemoteLoginCompletion(completion, remoteLoginHandler: remoteLoginHandler)
                case let .ssoAccountCreation(login, info):
                    self.completion(.ssoAccountCreation(login, info))
                }
            }
        navigator.push(LoginFlow(viewModel: viewModel), barStyle: .transparent, animated: true)
    }

    private func handleLocalLoginCompletion(_ completion: LocalLoginFlowViewModel.Completion,
                                            localLoginHandler: LocalLoginHandler) {
        switch completion {
        case .logout:
            self.completion(.logout)
        case let .completed(session, shouldResetMP, shouldRefreshKeychainMasterKey, loginFlowLogInfo):
            self.loadSessionServices(using: session,
                                     shouldChangeMasterPassword: shouldResetMP,
                                     shouldRefreshKeychainMasterKey: shouldRefreshKeychainMasterKey,
                                     logInfo: loginFlowLogInfo,
                                     isFirstLogin: false)
        case let .migration(migrationMode):
            currentSubCoordinator = self.makeMigrationCoordinator(with: migrationMode,
                                                                  localLoginHandler: localLoginHandler)
            currentSubCoordinator?.start()
        }
    }

    private func handleRemoteLoginCompletion(_ completion: RemoteLoginFlowViewModel.Completion,
                                             remoteLoginHandler: RemoteLoginHandler) {
        switch completion {
        case let .deviceUnlinking(remoteLoginSession, logInfo, remoteLoginHandler, loadActionPublisher):
            loadSession(using: remoteLoginSession,
                        loadActionPublisher: loadActionPublisher,
                        logInfo: logInfo,
                        remoteLoginHandler: remoteLoginHandler)
        case let .completed(session, logInfo):
            loadSessionServices(using: session, logInfo: logInfo, isFirstLogin: true)
        case let .migrateAccount(migrationInfos, validator):
            migrate(with: migrationInfos, validator: validator)
        }
    }

    func handle(error: Error) {
        self.sessionLogger.fatal("Failed to load session", error: error)
        self.completion(.logout)
    }
}

private extension LoginCoordinator {
    func startChangeMasterPasswordCoordinator(using sessionServices: SessionServicesContainer) {
        let currentSubCoordinator = AccountMigrationCoordinator(type: .masterPasswordToMasterPassword,
                                                                navigator: navigator,
                                                                sessionServices: sessionServices,
                                                                authTicket: nil,
                                                                logger: appServices.rootLogger[.session]) { [weak self] (result) in
            guard let self = self else {
                return
            }
            if case let .success(response) = result, case let .finished(newSession) = response {
                sessionServices.unload(reason: .masterPasswordChanged)
                self.loadSessionServices(using: newSession,
                                         shouldChangeMasterPassword: false,
                                         shouldRefreshKeychainMasterKey: false,
                                         logInfo: .init(loginMode: .masterPassword),
                                         isFirstLogin: false)
            }
        }
        currentSubCoordinator.start()
    }

    func makeMigrationCoordinator(with mode: LocalLoginFlowViewModel.Completion.MigrationMode,
                                  localLoginHandler: LocalLoginHandler) -> LocalLoginMigrationCoordinator {
        .init(navigator: navigator,
              appServices: appServices,
              localLoginHandler: localLoginHandler,
              logger: appServices.rootLogger[.session],
              mode: mode) { result in
            switch result {
            case let .failure(error):
                self.handle(error: error)
            case let .success(completion):
                switch completion {
                case .logout:
                    self.completion(.logout)
                case let .session(session):
                    self.loadSessionServices(using: session,
                                             logInfo: .init(loginMode: .masterPassword),
                                             isFirstLogin: false)
                }
            }
        }
    }
}

extension LoginCoordinator {
    func loadSessionServices(using session: Session,
                             shouldChangeMasterPassword: Bool = false,
                             shouldRefreshKeychainMasterKey: Bool = true,
                             logInfo: LoginFlowLogInfo,
                             isFirstLogin: Bool) {
        sessionServicesSubscription = SessionServicesContainer
            .buildSessionServices(from: session,
                                  appServices: self.appServices,
                                  logger: appServices.rootLogger[.session],
                                  loadingContext: .localLogin) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .success(sessionServices) where shouldChangeMasterPassword:
                    self.startChangeMasterPasswordCoordinator(using: sessionServices)
                case let .success(sessionServices):
                    sessionServices.activityReporter.logSuccessfulLogin(logInfo: logInfo, isFirstLogin: isFirstLogin)
                    if shouldRefreshKeychainMasterKey {
                        sessionServices.lockService.secureLockConfigurator.refreshMasterKeyExpiration()
                    }
                    self.completion(.servicesLoaded(sessionServices))
                case let .failure(error):
                    self.handle(error: error)
                }
            }
    }
}

extension ActivityReporterProtocol {
    func logSuccessfulLogin(logInfo: LoginFlowLogInfo, isFirstLogin: Bool) {
        report(UserEvent.Login(isBackupCode: logInfo.isBackupCode,
                               isFirstLogin: isFirstLogin,
                               mode: logInfo.loginMode,
                               status: .success,
                               verificationMode: logInfo.verificationMode))
    }

    func logSuccessfulLoginWithSso() {
        report(UserEvent.Login(isFirstLogin: false,
                               mode: .sso,
                               status: .success,
                               verificationMode: Definition.VerificationMode.none))
    }
}

private extension DeepLinkingServiceProtocol {
    func tokenPublisher() -> AnyPublisher<String, Never> {
        deepLinkPublisher
            .compactMap { deeplink -> String? in
                switch deeplink {
                case .userNotConnected(.accountAuthenticationToken(let token)):
                    return token
                default:
                    return nil
                }
            }
            .eraseToAnyPublisher()
    }
}

private struct SessionActivityProvider: LoginKit.SessionActivityReporterProvider {
    let appActivityReporter: UserTrackingAppActivityReporter

    init(appActivityReporter: UserTrackingAppActivityReporter) {
        self.appActivityReporter = appActivityReporter
    }

    func makeSessionActivityReporter(for login: Login, analyticsId: AnalyticsIdentifiers) -> ActivityReporterProtocol {
        UserTrackingSessionActivityReporter(appReporter: appActivityReporter,
                                            login: login,
                                            analyticsIdentifiers: analyticsId)
    }
}
