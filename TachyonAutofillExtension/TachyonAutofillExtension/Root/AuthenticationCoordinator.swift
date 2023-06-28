import Foundation
import LoginKit
import DashTypes
import CoreSession
import UIKit
import CoreKeychain
import CoreSettings
import SwiftTreats
import DashlaneAppKit
import CoreNetworking
import CoreUserTracking
import UIComponents

@MainActor
class AuthenticationCoordinator: Coordinator, SubcoordinatorOwner {

    enum InputMode {
        case loggedOut
        case servicesLoaded(SessionServicesContainer)
    }

    unowned var navigator: DashlaneNavigationController
    let appServices: AppServicesContainer
    let completion: @MainActor (Result<SessionServicesContainer, Error>) -> ()
    var subcoordinator: Coordinator?
    let inputMode: InputMode
    let localLoginFlowViewModelFactory: LocalLoginFlowViewModel.Factory
    
    enum AuthError: Error {
        case noUserConnected(details: String)
        case userCanceledAuthentication
        case ssoUserWithNoAccountCreated
        case migrationRequired
    }

    init(appServices: AppServicesContainer,
         navigator: DashlaneNavigationController,
         inputMode: InputMode = .loggedOut,
         localLoginFlowViewModelFactory: LocalLoginFlowViewModel.Factory,
         completion: @escaping @MainActor (Result<SessionServicesContainer, Error>) -> ()) {
        self.navigator = navigator
        self.appServices = appServices
        self.completion = completion
        self.inputMode = inputMode
        self.localLoginFlowViewModelFactory = localLoginFlowViewModelFactory
    }

    func start() {
        switch inputMode {
        case .loggedOut:
            guard let rawLogin: String = try? appServices.sessionsContainer.fetchCurrentLogin()?.email else {
                completion(.failure(AuthError.noUserConnected(details: "rl1")))
                return
            }
            let login = Login(rawLogin)
            Task {
                await connect(with: login)
            }
        case let .servicesLoaded(sessionServicesContainer):
            Task {
                await connect(with: sessionServicesContainer.session.login)
            }
        }
    }

    private func makeLoginHandler(for login: Login) -> LoginHandler {
        let cryptoEngineProvider = SessionCryptoEngineProvider(logger: appServices.rootLogger)
        return LoginHandler(sessionsContainer: appServices.sessionsContainer,
                            appApiClient: appServices.appAPIClient,
                            apiClient: appServices.appAPIClient,
                            deviceInfo: DeviceInfo.default,
                            logger: appServices.rootLogger[.session],
                            cryptoEngineProvider: cryptoEngineProvider) { [appServices] login in
            do {
                try? appServices.keychainService.removeMasterKey(for: login)
                try appServices.sessionsContainer.removeSessionDirectory(for: login)
                try appServices.sessionsContainer.saveCurrentLogin(nil)
            } catch {
                appServices.rootLogger.fatal("Failed to delete session data after invalidation", error: error)
            }
        }
    }

    private func connect(with login: Login) async {
        guard let deviceId = appServices.appSettings.deviceId else {
            fatalError("Device Id Not available")
        }
        let loginHandler = makeLoginHandler(for: login)

        do {
            let handler = try await loginHandler.createLocalLoginHandler(using: login, deviceId: deviceId, context: LoginContext(origin: .mobile))
            self.displayLocalLogin(using: handler)
        } catch {
            self.handle(error: error)
        }
    }

    private func displayLocalLogin(using loginHandler: LocalLoginHandler) {
        guard let userSecuritySettings = try? appServices.settingsManager.fetchOrCreateUserSettings(for: loginHandler.login) else {
            fatalError("Could not get user security settings")
        }

        guard let userSettings = try? appServices.settingsManager.fetchOrCreateSettings(for: loginHandler.login) else {
            fatalError("Could not get user settings")
        }

        let resetMasterPasswordService = ResetMasterPasswordService(login: loginHandler.login, settings: userSettings, keychainService: appServices.keychainService)

        let model = localLoginFlowViewModelFactory.make(localLoginHandler: loginHandler, resetMasterPasswordService: resetMasterPasswordService, userSettings: userSecuritySettings, email: loginHandler.login.email, context: .autofillExtension(cancelAction: cancelAction)) { [weak self] completion in
            guard let self = self else { return }
            self.handleLoginCompletion(completion, localLoginHandler: loginHandler)
        }
        navigator.setRootNavigation(LocalLoginFlow(viewModel: model), barStyle: .transparent, animated: false)
    }

    private func handleLoginCompletion(_ completionType: Result<LocalLoginFlowViewModel.Completion, Error>,
                                       localLoginHandler: LocalLoginHandler) {
        switch completionType {
        case .success(let completion):
            switch completion {
            case .logout:
                self.handle(error: AuthError.userCanceledAuthentication)
            case let .completed(session, _, _, logInfo, _, _):
                if case let .servicesLoaded(sessionServicesContainer) = self.inputMode {
                    sessionServicesContainer.activityReporter.logSuccessfulLocalLogin(logInfo)
                    self.completion(.success(sessionServicesContainer))
                    return
                }
                Task {
                    do {
                        let sessionServicesContainer = try await self.loadSession(session)
                        sessionServicesContainer.activityReporter.logSuccessfulLocalLogin(logInfo)
                        self.completion(.success(sessionServicesContainer))
                    } catch {
                        self.appServices.loginMetricsReporter.resetTimer(.login)
                        self.handle(error: error)
                    }
                }
            case .migration:
                self.handle(error: AuthError.migrationRequired)
            }
        case .failure(let error):
            self.handle(error: error)
        }
    }

    nonisolated func loadSession(_ session: Session) async throws -> SessionServicesContainer {
        try await SessionServicesContainer.load(for: session, appServices: appServices)
    }

    private func handle(error: Error) {
        self.navigator.presentedViewController?.dismiss(animated: true, completion: nil)
        self.completion(.failure(error))
    }

    private func cancelAction() {
        self.handle(error: AuthError.userCanceledAuthentication)
    }
}

fileprivate extension ActivityReporterProtocol {
    func logSuccessfulLocalLogin(_ logInfo: LoginFlowLogInfo) {
        report(UserEvent.Login(isBackupCode: logInfo.isBackupCode,
                               isFirstLogin: false,
                               mode: logInfo.loginMode,
                               status: .success,
                               verificationMode: logInfo.verificationMode))
    }
}
