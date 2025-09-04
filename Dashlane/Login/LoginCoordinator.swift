import Combine
import CoreCrypto
import CoreLocalization
import CoreSession
import CoreTypes
import CoreUserTracking
import LogFoundation
import Logger
import LoginKit
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight
import UIKit
import UserTrackingFoundation

@MainActor
class LoginCoordinator: Coordinator {

  enum LoginCompletionType {
    case servicesLoaded(SessionServicesContainer)
    case ssoAccountCreation(_ login: Login, SSOLoginInfo)
    case logout
  }

  enum LoginRequest {
    case postLaunchLogin(Login)
    case existingLogin(Login)
    case newLogin

    var login: Login? {
      switch self {
      case .postLaunchLogin(let login):
        return login
      case .existingLogin(let login):
        return login
      case .newLogin:
        return nil
      }
    }

    var shouldAnimatePush: Bool {
      switch self {
      case .postLaunchLogin:
        return false
      case .newLogin, .existingLogin:
        return true
      }
    }
  }

  let request: LoginRequest
  let navigator: Navigator
  let loginHandler: LoginStateMachine
  let appServices: AppServicesContainer
  let completion: (LoginCompletionType) -> Void
  var currentSubCoordinator: Coordinator?
  let sessionLogger: Logger

  var sessionServicesSubscription: AnyCancellable?

  init(
    request: LoginRequest,
    loginHandler: LoginStateMachine,
    appServices: AppServicesContainer,
    sessionLogger: Logger,
    navigator: Navigator,
    completion: @escaping (LoginCompletionType) -> Void
  ) {
    self.request = request
    self.navigator = navigator
    self.loginHandler = loginHandler
    self.completion = completion
    self.appServices = appServices
    self.sessionLogger = sessionLogger
  }

  func start() {
    let viewModel = appServices.makeLoginFlowViewModel(
      login: request.login,
      deviceId: appServices.globalSettings.deviceId,
      loginHandler: loginHandler,
      purchasePlanFlowProvider: PurchasePlanFlowProvider(appServices: appServices),
      sessionActivityReporterProvider: SessionActivityProvider(
        appActivityReporter: appServices.userTrackingAppActivityReporter),
      tokenPublisher: appServices.deepLinkingService.tokenPublisher(),
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
    navigator.push(LoginFlow(viewModel: viewModel), animated: request.shouldAnimatePush)
  }

  private func handleLocalLoginCompletion(_ completion: LocalLoginFlowViewModel.Completion) {
    switch completion {
    case .logout:
      self.completion(.logout)
    case let .completed(config, logInfo):
      self.loadSessionServices(using: config, logInfo: logInfo)
    case let .migration(migrationInfos):
      migrate(with: migrationInfos)
    case .cancel: break
    }
  }

  private func handleRemoteLoginCompletion(_ completion: RemoteLoginFlowViewModel.Completion) {
    switch completion {
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
      title: CoreL10n.kwErrorTitle,
      message: error.debugDescription, preferredStyle: .alert)
    alert.addAction(
      .init(
        title: CoreL10n.copyError, style: .default,
        handler: { _ in
          UIPasteboard.general.string = error.localizedDescription
          self.completion(.logout)
        }))
    alert.addAction(
      .init(
        title: CoreL10n.kwButtonOk,
        style: .default,
        handler: { _ in
          self.completion(.logout)
        }))
    self.navigator.present(alert, animated: true, completion: nil)
  }

  private func reloadSessionServicesAsynchronously(
    using sessionServices: SessionServicesContainer,
    localLoginConfiguration: LocalLoginConfiguration
  ) {
    Task {
      await sessionServices.unload(reason: .masterPasswordChanged)
      self.loadSessionServices(
        using: localLoginConfiguration,
        logInfo: .init(loginMode: .masterPassword)
      )
    }
  }
}

extension LoginCoordinator {
  fileprivate func migrateMasterPassword(using sessionServices: SessionServicesContainer) {
    let viewModel = sessionServices.makeMP2MPAccountMigrationViewModel(
      migrationContext: .accountRecovery
    ) { [weak self] result in
      guard let self else { return }
      self.navigator.dismiss()

      switch result {
      case let .failure(error):
        self.sessionLogger.fatal("Failed to change master password", error: error)
        self.handle(error: error)
      case let .success(newSession):
        self.reloadSessionServicesAsynchronously(
          using: sessionServices,
          localLoginConfiguration: LocalLoginConfiguration(
            session: newSession,
            shouldResetMP: false,
            shouldRefreshKeychainMasterKey: false,
            authenticationMode: .resetMasterPassword
          )
        )
      case .cancel:
        break
      }
    }

    self.navigator.present(
      MP2MPAccountMigrationFlowView(viewModel: viewModel),
      presentationStyle: .overFullScreen,
      animated: true
    )
  }
}

extension LoginCoordinator {
  func loadSessionServices(using config: LocalLoginConfiguration, logInfo: LoginFlowLogInfo) {
    let context = SessionLoadingContext.LocalContextOrigin.regular(
      reportedLoginMode: logInfo.loginMode)

    sessionServicesSubscription =
      SessionServicesContainer
      .buildSessionServices(
        from: config.session,
        appServices: self.appServices,
        logger: appServices.rootLogger[.session],
        loadingContext: .localLogin(
          .regular(reportedLoginMode: logInfo.loginMode),
          isRecoveryKeyUsed: config.newMasterPassword != nil)
      ) { [weak self] result in
        guard let self = self else { return }
        switch result {
        case let .success(sessionServices) where config.shouldResetMP:
          migrateMasterPassword(using: sessionServices)
        case let .success(sessionServices):
          sessionServices.activityReporter.logSuccessfulLogin(
            logInfo: logInfo, isFirstLogin: config.isFirstLogin)
          if config.shouldRefreshKeychainMasterKey {
            sessionServices.lockService.secureLockConfigurator.refreshMasterKeyExpiration()
          }
          if config.isRecoveryLogin, let newMasterPassword = config.newMasterPassword {
            changeMasterPassword(
              sessionServices: sessionServices, newMasterPassword: newMasterPassword)
          } else {
            self.completion(.servicesLoaded(sessionServices))
          }

        case .failure(CryptoEngineError.invalidHMAC)
        where config.session.configuration.info.loginOTPOption == .totp:
          recoverAuthenticatorIssues(using: config, logInfo: logInfo)

        case let .failure(error):
          self.handle(error: error)
        }
      }
  }

  func recoverAuthenticatorIssues(using config: LocalLoginConfiguration, logInfo: LoginFlowLogInfo)
  {
    do {
      try appServices.sessionContainer.removeSessionDirectory(for: config.session.login)
      let session = try appServices.sessionContainer.createSession(
        with: config.session.configuration,
        cryptoConfig: config.session.cryptoEngine.config)
      let config = LocalLoginConfiguration(
        session: session,
        shouldResetMP: config.shouldResetMP,
        shouldRefreshKeychainMasterKey: config.shouldRefreshKeychainMasterKey,
        isFirstLogin: config.isFirstLogin,
        newMasterPassword: config.newMasterPassword,
        authTicket: config.authTicket,
        authenticationMode: config.authenticationMode,
        verificationMode: config.verificationMode,
        isBackupCode: config.isBackupCode)
      self.loadSessionServices(using: config, logInfo: logInfo)
    } catch {
      self.handle(error: error)
    }
  }

  func loadSessionServices(using config: RemoteLoginConfiguration, logInfo: LoginFlowLogInfo) {
    sessionServicesSubscription =
      SessionServicesContainer
      .buildSessionServices(
        from: config.session,
        appServices: self.appServices,
        logger: appServices.rootLogger[.session],
        loadingContext: .remoteLogin(isRecoveryKeyUsed: config.isRecoveryLogin)
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
    let model = sessionServices.viewModelFactory.makePostARKChangeMasterPasswordViewModel(
      accountMigrationConfiguration: .masterPasswordToMasterPassword(
        session: sessionServices.session,
        masterPassword: newMasterPassword
      ),
      completion: { [weak self] result in
        guard let self else { return }

        switch result {
        case let .finished(session):
          self.reloadSessionServicesAsynchronously(
            using: sessionServices,
            localLoginConfiguration: LocalLoginConfiguration(
              session: session,
              shouldResetMP: false,
              shouldRefreshKeychainMasterKey: false,
              isRecoveryLogin: false,
              newMasterPassword: newMasterPassword,
              authenticationMode: .resetMasterPassword
            )
          )

        case .cancel:
          self.completion(.logout)
        }
      })
    let view = PostARKChangeMasterPasswordView(model: model)
    navigator.push(view)
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
