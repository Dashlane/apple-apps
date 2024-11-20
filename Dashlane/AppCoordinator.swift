import AuthenticatorKit
import Combine
import CoreFeature
import CoreNetworking
import CorePersonalData
import CoreSession
import CoreUserTracking
import DashTypes
import DesignSystem
import Logger
import LoginKit
import SwiftTreats
import SwiftUI
import TipKit
import UIComponents
import UIDelight
import UIKit

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

  @SharedUserDefault(
    key: Key.isPasswordAppFirstLaunch, userDefaults: ApplicationGroup.dashlaneUserDefaults)
  public var isFirstLaunch: Bool?

  var sessionServicesSubscription: AnyCancellable?
  private var cancellables: Set<AnyCancellable> = []
  lazy var sessionLogger = self.appServices.rootLogger[.session]
  lazy var navigator: DashlaneNavigationController = {
    let navigator = DashlaneNavigationController()
    navigator.view.backgroundColor = UIColor(.ds.background.default)
    navigator.setNavigationBarHidden(true, animated: false)
    navigator.navigationBar.applyStyle(.hidden())
    navigator.turnOnToaster()
    return navigator
  }()

  let mainMenuHandler = ApplicationMainMenuHandler()
  var onboardingCoordinator: Coordinator?

  @MainActor
  init(
    window: UIWindow,
    crashReporterService: CrashReporterService,
    appLaunchTimeStamp: TimeInterval
  ) {
    self.window = window
    self.crashReporterService = crashReporterService

    do {
      self.appServices = try AppServicesContainer(
        sessionLifeCycleHandler: self,
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
    setupTips()
    createSessionFromUITestCommandIfNeeded()
  }

  func initialSetup() {
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

  private func setupTips() {
    if #available(iOS 17, macOS 14, *) {
      do {
        Tips.showAllTipsForTesting()

        try Tips.configure([
          .displayFrequency(.monthly),
          .datastoreLocation(.applicationDefault),
        ])
      } catch {
        sessionLogger.error("Tips configuration failed", error: error)
      }
    }
  }

  func logAppLaunch() {
    if appServices.globalSettings.isFirstLaunch {
      appServices.activityReporter.trackInstall()
    }
  }

  func configureAdTracking() {
    AdTracking.start()
    if appServices.globalSettings.isFirstLaunch {
      AdjustService.startTracking(installationID: appServices.activityReporter.installationId)
    }
  }

  func configureAbTesting() {
    Task {
      await appServices.unauthenticatedABTestingService.setupNonAuthenticatedTesting()
    }
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
    let onboardingViewModel = PreAccountCreationOnboardingViewModel(
      keychainService: appServices.keychainService, logger: appServices.rootLogger
    ) { [weak self] nextStep in
      guard let `self` = self else { return }
      switch nextStep {
      case .accountCreation:
        self.createAccount()
      case .login:
        self.login()
      }
    }

    navigator.viewControllers = [
      UIHostingController(rootView: PreAccountCreationOnboardingView(model: onboardingViewModel))
    ]
    window.rootViewController = navigator

    showVersionValidityAlertIfNeeded()
  }

  private func showVersionValidityAlertIfNeeded() {
    appServices.versionValidityService.shouldShowAlertPublisher().receive(on: DispatchQueue.main)
      .sink { [weak self] status in
        guard let self = self else { return }
        let alertDismissed = {
          self.appServices.versionValidityService.messageDismissed(for: status)
        }
        guard
          let alert = VersionValidityAlert(status: status, alertDismissed: alertDismissed)
            .makeAlert()
        else {
          return
        }

        self.navigator.present(alert, animated: true)
        self.appServices.versionValidityService.messageShown(for: status)
      }.store(in: &cancellables)
  }

  @MainActor
  func createAccount() {
    let model = appServices.makeAccountCreationFlowViewModel {
      [weak self] (result: AccountCreationFlowViewModel.CompletionResult) in
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
        self.startSSOAccountCreation(
          for: email,
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
    currentSubCoordinator = LoginCoordinator(
      loginHandler: loginHandler,
      appServices: appServices,
      sessionLogger: sessionLogger,
      navigator: navigator,
      login: login
    ) { [weak self] result in
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

          self.startSSOAccountCreation(
            for: DashTypes.Email(login.email),
            initialStep: .authenticate(info.serviceProviderURL),
            isNitroProvider: info.isNitroProvider)
        }
      }
    }
    currentSubCoordinator?.start()
  }

  func startConnectedCoordinator(using sessionServices: SessionServicesContainer) {
    currentSubCoordinator = ConnectedCoordinator(
      sessionServices: sessionServices,
      window: window,
      logoutHandler: self,
      applicationMainMenuHandler: mainMenuHandler)
    currentSubCoordinator?.start()
  }

  private func makeLoginHandler() -> LoginHandler {
    return LoginHandler(
      sessionsContainer: appServices.sessionContainer,
      appApiClient: self.appServices.appAPIClient,
      deviceInfo: DeviceInfo.default,
      logger: sessionLogger,
      cryptoEngineProvider: appServices.sessionCryptoEngineProvider,
      removeLocalDataHandler: appServices.sessionCleaner.removeLocalData)
  }

  func startSSOAccountCreation(
    for email: DashTypes.Email,
    initialStep: SSOAccountCreationCoordinator.Step,
    isNitroProvider: Bool
  ) {

    currentSubCoordinator = SSOAccountCreationCoordinator(
      email: email,
      appServices: appServices,
      navigator: navigator,
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
