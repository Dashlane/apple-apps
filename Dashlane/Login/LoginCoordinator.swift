import Combine
import CoreLocalization
import CoreSession
import CoreUserTracking
import DashTypes
import Logger
import LoginKit
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight
import UIKit

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

  var sessionServicesSubscription: AnyCancellable?

  init(
    loginHandler: LoginHandler,
    appServices: AppServicesContainer,
    sessionLogger: Logger,
    navigator: Navigator,
    login: Login?,
    completion: @escaping (LoginCompletionType) -> Void
  ) {
    self.navigator = navigator
    self.loginHandler = loginHandler
    self.completion = completion
    self.appServices = appServices
    self.sessionLogger = sessionLogger
    self.login = login
    loginKitServices = appServices.makeLoginKitServicesContainer()
  }

  func start() {
    let viewModel = loginKitServices.makeLoginFlowViewModel(
      login: login,
      deviceId: appServices.globalSettings.deviceId,
      loginHandler: loginHandler,
      purchasePlanFlowProvider: PurchasePlanFlowProvider(appServices: appServices),
      sessionActivityReporterProvider: SessionActivityProvider(
        appActivityReporter: appServices.activityReporter),
      tokenPublisher: appServices.deepLinkingService.tokenPublisher(),
      versionValidityAlertProvider: VersionValidityAlert.errorAlert(),
      context: .passwordApp
    ) { [weak self] completion in
      guard let self = self else { return }
      switch completion {
      case .logout:
        self.completion(.logout)
      case let .localLogin(completion):
        self.handleLocalLoginCompletion(completion)
      case let .remoteLogin(completion):
        self.handleRemoteLoginCompletion(completion)
      case let .ssoAccountCreation(login, info):
        self.completion(.ssoAccountCreation(login, info))
      }
    }
    navigator.push(LoginFlow(viewModel: viewModel), barStyle: .transparent, animated: true)
  }

  private func handleLocalLoginCompletion(_ completion: LocalLoginFlowViewModel.Completion) {
    switch completion {
    case .logout:
      self.completion(.logout)
    case let .completed(
      session, shouldResetMP, shouldRefreshKeychainMasterKey, loginFlowLogInfo, isRecoveryLogin,
      newMasterPassword):
      self.loadSessionServices(
        using: session,
        shouldChangeMasterPassword: shouldResetMP,
        shouldRefreshKeychainMasterKey: shouldRefreshKeychainMasterKey,
        logInfo: loginFlowLogInfo,
        isFirstLogin: false,
        isRecoveryLogin: isRecoveryLogin,
        newMasterPassword: newMasterPassword)
    case let .migration(migrationMode, localLoginHandler):
      currentSubCoordinator = self.makeMigrationCoordinator(
        with: migrationMode,
        localLoginHandler: localLoginHandler)
      currentSubCoordinator?.start()
    case .cancel: break
    }
  }

  private func handleRemoteLoginCompletion(_ completion: RemoteLoginFlowViewModel.Completion) {
    switch completion {
    case let .deviceUnlinking(remoteLoginSession, logInfo, remoteLoginHandler, loadActionPublisher):
      loadSession(
        using: remoteLoginSession,
        loadActionPublisher: loadActionPublisher,
        logInfo: logInfo,
        remoteLoginHandler: remoteLoginHandler)
    case let .completed(config, logInfo):
      loadSessionServices(using: config, logInfo: logInfo)
    case let .migrateAccount(migrationInfos):
      migrate(with: migrationInfos)
    case .logout, .dismiss:
      self.completion(.logout)
    }
  }

  func handle(error: Error) {
    self.sessionLogger.fatal("Failed to load session", error: error)
    if DiagnosticMode.isEnabled {
      self.displayErrorAndLogout(error: error)
    } else {
      self.completion(.logout)
    }
  }

  func displayErrorAndLogout(error: Error) {
    guard DiagnosticMode.isEnabled else { return }
    let alert = UIAlertController(
      title: CoreLocalization.L10n.Core.kwErrorTitle,
      message: error.debugDescription, preferredStyle: .alert)
    alert.addAction(
      .init(
        title: CoreLocalization.L10n.Core.copyError, style: .default,
        handler: { _ in
          UIPasteboard.general.string = error.localizedDescription
          self.completion(.logout)
        }))
    alert.addAction(
      .init(
        title: CoreLocalization.L10n.Core.kwButtonOk,
        style: .default,
        handler: { _ in
          self.completion(.logout)
        }))
    self.navigator.present(alert, animated: true)
  }
}

extension LoginCoordinator {
  fileprivate func startChangeMasterPasswordCoordinator(
    using sessionServices: SessionServicesContainer
  ) {
    let currentSubCoordinator = AccountMigrationCoordinator(
      type: .masterPasswordToMasterPassword,
      navigator: navigator,
      sessionServices: sessionServices,
      authTicket: nil,
      logger: appServices.rootLogger[.session]
    ) { [weak self] (result) in
      guard let self = self else {
        return
      }
      switch result {
      case let .failure(error):
        self.sessionLogger.fatal("Failed to change master password", error: error)
        self.handle(error: error)
      case let .success(response):
        if case let .finished(newSession) = response {
          Task {
            await sessionServices.unload(reason: .masterPasswordChanged)
            self.loadSessionServices(
              using: newSession,
              shouldChangeMasterPassword: false,
              shouldRefreshKeychainMasterKey: false,
              logInfo: .init(loginMode: .masterPassword),
              isFirstLogin: false,
              isRecoveryLogin: false)
          }

        }
      }
    }
    currentSubCoordinator.start()
  }

  fileprivate func makeMigrationCoordinator(
    with mode: LocalLoginFlowViewModel.Completion.MigrationMode,
    localLoginHandler: LocalLoginHandler
  ) -> LocalLoginMigrationCoordinator {
    .init(
      navigator: navigator,
      appServices: appServices,
      localLoginHandler: localLoginHandler,
      logger: appServices.rootLogger[.session],
      mode: mode
    ) { result in
      switch result {
      case let .failure(error):
        self.handle(error: error)
      case let .success(completion):
        switch completion {
        case .logout:
          self.completion(.logout)
        case let .session(session):
          self.loadSessionServices(
            using: session,
            logInfo: .init(loginMode: .masterPassword),
            isFirstLogin: false,
            isRecoveryLogin: false)
        }
      }
    }
  }
}

extension LoginCoordinator {
  func loadSessionServices(
    using session: Session,
    shouldChangeMasterPassword: Bool = false,
    shouldRefreshKeychainMasterKey: Bool = true,
    logInfo: LoginFlowLogInfo,
    isFirstLogin: Bool,
    isRecoveryLogin: Bool,
    newMasterPassword: String? = nil
  ) {
    sessionServicesSubscription =
      SessionServicesContainer
      .buildSessionServices(
        from: session,
        appServices: self.appServices,
        logger: appServices.rootLogger[.session],
        loadingContext: .localLogin(isRecoveryLogin)
      ) { [weak self] result in
        guard let self = self else { return }
        switch result {
        case let .success(sessionServices) where shouldChangeMasterPassword:
          self.startChangeMasterPasswordCoordinator(using: sessionServices)
        case let .success(sessionServices):
          sessionServices.activityReporter.logSuccessfulLogin(
            logInfo: logInfo, isFirstLogin: isFirstLogin)
          if shouldRefreshKeychainMasterKey {
            sessionServices.lockService.secureLockConfigurator.refreshMasterKeyExpiration()
          }
          if isRecoveryLogin, let newMasterPassword = newMasterPassword {
            changeMasterPassword(
              sessionServices: sessionServices, newMasterPassword: newMasterPassword)
          } else {
            self.completion(.servicesLoaded(sessionServices))
          }
        case let .failure(error):
          self.handle(error: error)
        }
      }
  }

  func loadSessionServices(using config: RemoteLoginConfiguration, logInfo: LoginFlowLogInfo) {
    sessionServicesSubscription =
      SessionServicesContainer
      .buildSessionServices(
        from: config.session,
        appServices: self.appServices,
        logger: appServices.rootLogger[.session],
        loadingContext: .remoteLogin(config.isRecoveryLogin)
      ) { [weak self] result in
        guard let self = self else { return }
        switch result {
        case let .success(sessionServices):
          sessionServices.activityReporter.logSuccessfulLogin(logInfo: logInfo, isFirstLogin: true)
          if let pin = config.pinCode {
            try? sessionServices.lockService.secureLockConfigurator.enablePinCode(pin)
          }
          if config.shouldEnableBiometry {
            try? sessionServices.lockService.secureLockConfigurator.enableBiometry()
          }
          if config.isRecoveryLogin, let newMasterPassword = config.newMasterPassword {
            changeMasterPassword(
              sessionServices: sessionServices, newMasterPassword: newMasterPassword)
          } else {
            self.completion(.servicesLoaded(sessionServices))
          }
        case let .failure(error):
          self.handle(error: error)
        }
      }
  }

  func changeMasterPassword(sessionServices: SessionServicesContainer, newMasterPassword: String) {
    do {
      let accountCryptoChangerService = try sessionServices.makeAccountCryptoChangerService(
        newMasterPassword: newMasterPassword)
      let model = sessionServices.viewModelFactory.makePostARKChangeMasterPasswordViewModel(
        accountCryptoChangerService: accountCryptoChangerService,
        completion: { result in
          switch result {
          case let .finished(session):
            Task {
              await sessionServices.unload(reason: .masterPasswordChanged)
              self.loadSessionServices(
                using: session,
                shouldChangeMasterPassword: false,
                shouldRefreshKeychainMasterKey: false,
                logInfo: .init(loginMode: .masterPassword),
                isFirstLogin: false,
                isRecoveryLogin: true)
            }

          case .cancel:
            self.completion(.logout)
          }
        })
      let view = PostARKChangeMasterPasswordView(model: model)
      navigator.push(view)
    } catch {
      self.handle(error: error)
    }
  }
}

extension ActivityReporterProtocol {
  func logSuccessfulLogin(logInfo: LoginFlowLogInfo, isFirstLogin: Bool) {
    report(
      UserEvent.Login(
        isBackupCode: logInfo.isBackupCode,
        isFirstLogin: isFirstLogin,
        mode: logInfo.loginMode,
        status: .success,
        verificationMode: logInfo.verificationMode))
  }

  func logSuccessfulLoginWithSso() {
    report(
      UserEvent.Login(
        isFirstLogin: false,
        mode: .sso,
        status: .success,
        verificationMode: Definition.VerificationMode.none))
  }
}

extension DeepLinkingServiceProtocol {
  fileprivate func tokenPublisher() -> AnyPublisher<String, Never> {
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

  func makeSessionActivityReporter(for login: Login, analyticsId: AnalyticsIdentifiers)
    -> ActivityReporterProtocol
  {
    UserTrackingSessionActivityReporter(
      appReporter: appActivityReporter,
      login: login,
      analyticsIdentifiers: analyticsId)
  }
}
