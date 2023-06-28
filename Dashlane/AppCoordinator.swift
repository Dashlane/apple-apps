import UIKit
import SwiftUI
import Combine
import CoreNetworking
import CoreSession
import CoreUserTracking
import CorePersonalData
import CoreFeature
import DashTypes
import UIDelight
import Logger
import DashlaneAppKit
import SwiftTreats
import DesignSystem
import UIComponents
import LoginKit
import AuthenticatorKit

@MainActor
class AppCoordinator: Coordinator {

    enum Key: String, CustomStringConvertible {
        var description: String {
            return rawValue
        }
        case isPasswordAppFirstLaunch
    }

    private(set) var appServices: AppServicesContainer!

    let crashReporterService: CrashReporterService
    let window: UIWindow

    @Published
    var currentSubCoordinator: Coordinator?

    var connectedCoordinator: ConnectedCoordinator? {
        return currentSubCoordinator as? ConnectedCoordinator
    }

    @SharedUserDefault(key: Key.isPasswordAppFirstLaunch, userDefaults: ApplicationGroup.dashlaneUserDefaults)
    public var isFirstLaunch: Bool?

    var sessionServicesSubscription: AnyCancellable?
    private var cancellables: Set<AnyCancellable> = []
    lazy var sessionLogger = self.appServices.rootLogger[.session]
    lazy var navigator: DashlaneNavigationController = {
        let navigator = DashlaneNavigationController()
        navigator.view.backgroundColor = FiberAsset.mainBackground.color
        navigator.setNavigationBarHidden(true, animated: false)
        navigator.navigationBar.applyStyle(.hidden())
        navigator.turnOnToaster()
        return navigator
    }()

    let mainMenuHandler = ApplicationMainMenuHandler()
    var onboardingCoordinator: Coordinator?

    @MainActor
    init(window: UIWindow,
         crashReporterService: CrashReporterService,
         appLaunchTimeStamp: TimeInterval) {
        self.window = window
        self.crashReporterService = crashReporterService

        do {
            self.appServices = try AppServicesContainer(sessionLifeCycleHandler: self,
                                                        crashReporter: crashReporterService,
                                                        appLaunchTimeStamp: appLaunchTimeStamp)
        } catch {
            fatalError("App Services failed: \(error)")
        }
    }

    func start() {
        initialSetup()
        logAppLaunch()

        window.rootViewController = navigator
        window.makeKeyAndVisible()
        if PreAccountCreationOnboardingViewModel.shouldDeleteLocalData {
                        showOnboarding()
        } else {
                        createSessionFromSavedLogin()
        }
        setupDeepLinking()
        createSessionFromUITestCommandIfNeeded()
        logAuthenticatorOnAppLaunch()
    }

    func initialSetup() {
                PremiumService.setup()
        configureAdTracking()
        configureAppearance()
        configureAbTesting()
        appServices.notificationService.registerForRemoteNotifications()
        checkVersionValidity()
    }

    private func setupDeepLinking() {
        self.appServices.deepLinkingService
            .deepLinkPublisher
            .sink { [weak self] in
                guard let self = self else { return }
                self.didReceiveDeepLink($0)
            }.store(in: &cancellables)
    }

    func logAppLaunch() {
                        if appServices.globalSettings.isFirstLaunch {
            appServices.activityReporter.trackInstall()
        }
    }

    func logAuthenticatorOnAppLaunch() {
        guard isFirstLaunch ?? true else {
            return
        }
        let authenticatorDatabaseService = AuthenticatorDatabaseService(logger: self.appServices.rootLogger[.localCommunication])
        authenticatorDatabaseService.codesPublisher.sinkOnce { [weak self] codes in
            guard let self = self else {
                return
            }
            self.appServices.activityReporter.report(UserEvent.PasswordManagerLaunch(authenticatorOtpCodesCount: codes.count,
                                                                                     hasAuthenticatorInstalled: Authenticator.isOnDevice,
                                                                                     isFirstLaunch: true))
            self.isFirstLaunch = false
        }
    }

        func configureAdTracking() {
        Task.detached(priority: .background) { [appServices] in
            guard let appServices = appServices else { return }
            AdTracking.start()
            AdjustService.startTracking(installationID: appServices.activityReporter.installationId)
        }
    }

    func configureAbTesting() {
        appServices.unauthenticatedABTestingService.setupNonAuthenticatedTesting()
    }

    func checkVersionValidity() {
        appServices.versionValidityService.checkVersionValidity()
    }

        func createSessionFromSavedLogin() {
        do {
            guard let login = try appServices.sessionContainer.fetchCurrentLogin() else {
                self.showOnboarding()
                return
            }
            self.login(with: login)
        } catch {
            sessionLogger.error("retrieve last login failed", error: error)
            self.showOnboarding()
        }
    }

        func showOnboarding() {
        let onboardingViewModel = PreAccountCreationOnboardingViewModel(keychainService: appServices.keychainService, logger: appServices.rootLogger) { [weak self] nextStep in
            guard let `self` = self else { return }
            switch nextStep {
            case .accountCreation:
                self.createAccount()
            case .login:
                self.login()
            }
        }

        navigator.viewControllers = [UIHostingController(rootView: PreAccountCreationOnboardingView(model: onboardingViewModel))]
        window.rootViewController = navigator

        showVersionValidityAlertIfNeeded()
    }

        private func showVersionValidityAlertIfNeeded() {
        appServices.versionValidityService.shouldShowAlertPublisher().receive(on: DispatchQueue.main).sink { [weak self] status in
            guard let self = self else { return }
            let alertDismissed = { self.appServices.versionValidityService.messageDismissed(for: status) }
            guard let alert = VersionValidityAlert(status: status, alertDismissed: alertDismissed).makeAlert() else {
                return
            }

            self.navigator.present(alert, animated: true)
            self.appServices.versionValidityService.messageShown(for: status)
        }.store(in: &cancellables)
    }

    @MainActor
    func createAccount() {
        let model = appServices.makeAccountCreationFlowViewModel { [weak self] (result: AccountCreationFlowViewModel.CompletionResult) in
            guard let self = self else {
                return
            }
            switch result {
            case .finished(let sessionServices):
                AdTracking.registerAccountCreation()
                self.startConnectedCoordinator(using: sessionServices)

            case .login(let login):
                self.login(with: login)

            case let .startSSO(email: email, info: info):
                self.startSSOAccountCreation(for: email,
                                             initialStep: .authenticate(info.serviceProviderURL),
                                             isNitroProvider: info.isNitroProvider)
            case .cancel:
                self.showOnboarding()
            }
        }
        navigator.push(AccountCreationFlow(model: model))
    }

    func login(with login: Login? = nil) {
        if window.rootViewController != navigator {
            window.rootViewController = navigator
        }
        let loginHandler = makeLoginHandler()
        currentSubCoordinator = LoginCoordinator(loginHandler: loginHandler,
                                                 appServices: appServices,
                                                 sessionLogger: sessionLogger,
                                                 navigator: navigator,
                                                 login: login) {[weak self] result in
                                                    guard let self = self else {
                                                        return
                                                    }
                                                    DispatchQueue.main.async {
                                                        switch result {
                                                        case .logout:
                                                            self.showOnboarding()
                                                        case let .servicesLoaded(sessionServices):
                                                            self.startConnectedCoordinator(using: sessionServices)
                                                        case let .ssoAccountCreation(login, info):

                                                            self.startSSOAccountCreation(for: DashTypes.Email(login.email),
                                                                                         initialStep: .authenticate(info.serviceProviderURL),
                                                                                         isNitroProvider: info.isNitroProvider)
                                                        }
                                                    }
        }
        currentSubCoordinator?.start()
    }

    func startConnectedCoordinator(using sessionServices: SessionServicesContainer) {
        currentSubCoordinator = ConnectedCoordinator(sessionServices: sessionServices,
                                                     window: window,
                                                     logoutHandler: self,
                                                     applicationMainMenuHandler: mainMenuHandler)
        currentSubCoordinator?.start()
    }

    private func makeLoginHandler() -> LoginHandler {
        return LoginHandler(sessionsContainer: appServices.sessionContainer,
                            appApiClient: self.appServices.appAPIClient,
                            apiClient: self.appServices.appAPIClient,
                            deviceInfo: DeviceInfo.default,
                            logger: sessionLogger,
                            cryptoEngineProvider: appServices.sessionCryptoEngineProvider,
                            removeLocalDataHandler: appServices.sessionCleaner.removeLocalData)
    }

    func startSSOAccountCreation(for email: DashTypes.Email,
                                 initialStep: SSOAccountCreationCoordinator.Step,
                                 isNitroProvider: Bool) {

        currentSubCoordinator = SSOAccountCreationCoordinator(email: email,
                                                              appServices: appServices,
                                                              navigator: navigator,
                                                              isEmailMarketingOptInRequired: appServices.userCountryProvider.userCountry.isEu,
                                                              logger: sessionLogger,
                                                              initialStep: initialStep,
                                                              isNitroProvider: isNitroProvider,
                                                              completion: { [weak self] result in
                                                                    DispatchQueue.main.async {
                                                                        switch result {
                                                                        case .cancel:
                                                                            self?.showOnboarding()
                                                                        case let .accountCreated(sessionServices):
                                                                            self?.startConnectedCoordinator(using: sessionServices)
                                                                        }
                                                                    }

        })
        currentSubCoordinator?.start()
    }
}
