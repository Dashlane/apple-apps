import UIKit
import SwiftUI
import CoreNetworking
import CoreSession
import Combine
import CorePersonalData
import DashlaneReportKit
import DashTypes
import UIDelight
import Logger
import DashlaneAppKit
import SwiftTreats
import CoreUserTracking
import DesignSystem
import UIComponents

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
        if LocalDataRemover.shouldDeleteLocalData {
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
        appServices.installerLogService.app.logAppLaunch()

                        appServices.installerLogService.trackInstall()
        if appServices.globalSettings.isFirstLaunch {
            appServices.activityReporter.trackInstall()
        }
    }

    func logAuthenticatorOnAppLaunch() {
        guard isFirstLaunch ?? true else {
            return
        }

        appServices.activityReporter.report(UserEvent.PasswordManagerLaunch(authenticatorOtpCodesCount: appServices.authenticatorDatabaseService.codes.count,
                                                                            hasAuthenticatorInstalled: hasAuthenticatorApp(),
                                                                            isFirstLaunch: true))
        isFirstLaunch = false
    }

    func hasAuthenticatorApp() -> Bool {
      return UIApplication.shared.canOpenURL(DashlaneURLFactory.authenticator)
    }

        func configureAdTracking() {
        Task.detached(priority: .background) { [appServices] in
            guard let appServices = appServices else { return }
            AdTracking.start()
            AdjustService.startTracking(usingAnonymousDeviceId: appServices.globalSettings.anonymousDeviceId,
                                        installationID: appServices.activityReporter.installationId,
                                        isFirstLaunch: appServices.globalSettings.isFirstLaunch)
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
        onboardingCoordinator = PreAccountCreationOnboardingCoordinator(navigator: navigator,
                                                                        appServices: appServices) { [weak self] nextStep in
            guard let `self` = self else { return }
            switch nextStep {
            case .accountCreation:
                self.createAccount()
            case .login:
                self.login()
            }
        }
        onboardingCoordinator?.start()

        window.rootViewController = navigator
    }

    func createAccount() {
        let accountCreationHandler = AccountCreationHandler(apiClient: appServices.appAPIClient)
        currentSubCoordinator = AccountCreationCoordinator(navigator: navigator,
                                                           isEmailMarketingOptInRequired: appServices.userCountryProvider.userCountry.isEu,
                                                           logger: sessionLogger,
                                                           accountCreationHandler: accountCreationHandler,
                                                           appServices: appServices,
                                                           completion: { [weak self] result in
                                                            DispatchQueue.main.async {
                                                                guard let self = self else {
                                                                    return
                                                                }

                                                                switch result {
                                                                case .finished(let sessionServices):
                                                                    AdTracking.registerAccountCreation()
                                                                    self.startConnectedCoordinator(using: sessionServices)
                                                                case .login(let login):
                                                                    self.login(with: login)
                                                                case .cancel:
                                                                    self.showOnboarding()
                                                                }
                                                            }
        })
        currentSubCoordinator?.start()
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

                                                            let accountCreationHandler = AccountCreationHandler(apiClient: self.appServices.appAPIClient)
                                                            self.startSSOAccountCreation(for: login,
                                                                                         accountCreationHandler: accountCreationHandler,
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
                            apiClient: self.appServices.appAPIClient,
                            deviceInfo: DeviceInfo.default,
                            logger: sessionLogger,
                            cryptoEngineProvider: appServices.sessionCryptoEngineProvider,
                            removeLocalDataHandler: appServices.sessionCleaner.removeLocalData)
    }

    func startSSOAccountCreation(for login: Login,
                                 accountCreationHandler: AccountCreationHandler,
                                 initialStep: SSOAccountCreationCoordinator.Step,
                                 isNitroProvider: Bool) {

        currentSubCoordinator = SSOAccountCreationCoordinator(email: DashTypes.Email(login.email),
                                                              appServices: appServices,
                                                              navigator: navigator,
                                                              accountCreationHandler: accountCreationHandler,
                                                              isEmailMarketingOptInRequired: appServices.userCountryProvider.userCountry.isEu,
                                                              logger: sessionLogger,
                                                              initialStep: initialStep,
                                                              ssoLogger: appServices.installerLogService.sso,
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
