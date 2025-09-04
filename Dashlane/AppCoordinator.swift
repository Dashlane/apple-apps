import AuthenticatorKit
import Combine
import CoreFeature
import CoreMainMenu
import CoreNetworking
import CorePersonalData
import CoreSession
import CoreTypes
import DashlaneAPI
import DesignSystem
import Logger
import LoginKit
import SwiftTreats
import SwiftUI
import TipKit
import UIDelight
import UIKit
import UserTrackingFoundation

@MainActor
class AppCoordinator: Coordinator {

  enum Key: String, CustomStringConvertible {
    var description: String {
      return rawValue
    }
    case isPasswordAppFirstLaunch
  }

  private(set) var appServices: AppServicesContainer!

  let crashReporter: CrashReporter
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
  lazy var navigator: UINavigationController = {
    let navigator = MainMenuHandlerNavigationController()
    navigator.view.backgroundColor = UIColor(.ds.background.default)
    navigator.turnOnToaster()
    return navigator
  }()

  let mainMenuHandler = ApplicationMainMenuHandler()
  var onboardingCoordinator: Coordinator?

  @MainActor
  init(
    window: UIWindow,
    crashReporter: CrashReporter,
    appLaunchTimeStamp: TimeInterval
  ) async {
    self.window = window
    self.crashReporter = crashReporter

    do {
      self.appServices = try await AppServicesContainer(
        sessionLifeCycleHandler: self,
        crashReporter: crashReporter,
        appLaunchTimeStamp: appLaunchTimeStamp)
    } catch {
      fatalError("App Services failed: \(error)")
    }
  }

  func start() {
    window.rootViewController = navigator

    initialSetup()
    logAppLaunch()

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
    AnyTransition.precompileUnlockTransition()
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

  func logAppLaunch() {
    if appServices.globalSettings.isFirstLaunch {
      appServices.userTrackingAppActivityReporter.trackInstall()
    }
  }

  func configureAdTracking() {
    AdTracking.start()
    if appServices.globalSettings.isFirstLaunch {
      AdjustService.startTracking(
        installationID: appServices.userTrackingAppActivityReporter.installationId)
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
      self.login(with: .postLaunchLogin(login))
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

    navigator.setRootNavigation(
      PreAccountCreationOnboardingView(model: onboardingViewModel), animated: false)
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
  func createAccount(initialStep: AccountCreationFlowViewModel.Step = .email) {
    let model = appServices.makeAccountCreationFlowViewModel(
      initialStep: initialStep, stateMachine: appServices.accountCreationFlowStateMachine,
      sessionServicesLoader: appServices.sessionServicesLoader
    ) { [weak self] (result: AccountCreationFlowViewModel.CompletionResult) in
      guard let self = self else {
        return
      }
      switch result {
      case .finished(let sessionServices):
        AdTracking.registerAccountCreation()
        self.startConnectedCoordinator(using: sessionServices)
      case .cancel:
        self.showOnboarding()
      }
    }
    navigator.push(AccountCreationFlow(model: model))
  }

  func login(with request: LoginCoordinator.LoginRequest = .newLogin) {
    if window.rootViewController != navigator {
      window.rootViewController = navigator
    }
    let loginHandler = makeLoginHandler()
    currentSubCoordinator = LoginCoordinator(
      request: request,
      loginHandler: loginHandler,
      appServices: appServices,
      sessionLogger: sessionLogger,
      navigator: navigator
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
          self.createAccount(initialStep: .create(.sso(email: CoreTypes.Email(login.email), info)))
        }
      }
    }
    currentSubCoordinator?.start()
  }

  func startConnectedCoordinator(using sessionServices: SessionServicesContainer) {
    currentSubCoordinator = ConnectedCoordinator(
      sessionServices: sessionServices,
      window: window,
      appRootNavigationViewController: navigator,
      logoutHandler: self,
      applicationMainMenuHandler: mainMenuHandler)
    currentSubCoordinator?.start()
  }

  private func makeLoginHandler() -> LoginStateMachine {
    return LoginStateMachine(
      sessionsContainer: appServices.sessionContainer,
      appApiClient: self.appServices.appAPIClient,
      nitroAPIClient: appServices.nitroClient,
      deviceInfo: DeviceInfo.default,
      logger: sessionLogger,
      cryptoEngineProvider: appServices.sessionCryptoEngineProvider,
      keychainService: appServices.keychainService,
      loginSettingsProvider: appServices,
      sessionCleaner: appServices.sessionCleaner,
      activityReporter: appServices.activityReporter,
      remoteLogger: appServices.remoteLogger)
  }
}

extension AppServicesContainer: LoginSettingsProvider {
  func makeSettings(for login: CoreTypes.Login) throws -> LoginSettings {
    try LoginSettingsImpl(
      login: login, settingsManager: spiegelSettingsManager, keychainService: keychainService)
  }

}

extension AppServicesContainer: AccountCreationSettingsProvider {
  func initialSettings(
    using cryptoConfig: CoreTypes.CryptoRawConfig, remoteCryptoEngine: any CoreTypes.CryptoEngine,
    login: CoreTypes.Login
  ) throws -> CoreSessionSettings {
    let initialSettings = try Settings(cryptoConfig: cryptoConfig, email: login.email)
      .makeTransactionContent()
      .encrypt(using: remoteCryptoEngine)
      .base64EncodedString()
    return CoreSessionSettings(content: initialSettings, time: Int(Timestamp.now.rawValue))
  }
}

extension AppServicesContainer: AccountCreationSharingKeysProvider {
  func sharingKeys(using cryptoEngine: CoreTypes.CryptoEngine) throws
    -> DashlaneAPI.AccountCreateUserSharingKeys
  {
    return try AccountCreateUserSharingKeys.makeAccountDefault(privateKeyCryptoEngine: cryptoEngine)
  }
}
