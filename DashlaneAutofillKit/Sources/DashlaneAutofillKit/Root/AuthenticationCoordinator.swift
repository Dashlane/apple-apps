import CoreKeychain
import CoreNetworking
import CoreSession
import CoreSettings
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import LoginKit
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight
import UIKit
import UserTrackingFoundation

@MainActor
class AuthenticationCoordinator: Coordinator, SubcoordinatorOwner {

  enum InputMode {
    case loggedOut
    case servicesLoaded(SessionServicesContainer)
  }

  unowned var navigator: UINavigationController
  let appServices: AppServicesContainer
  let completion: @MainActor (Result<SessionServicesContainer, Error>) -> Void
  var subcoordinator: Coordinator?
  let inputMode: InputMode
  let localLoginFlowViewModelFactory: LocalLoginFlowViewModel.Factory

  @Loggable
  enum AuthError: Error {
    @LogPublicPrivacy
    case noUserConnected(details: String)
    case userCanceledAuthentication
    case ssoUserWithNoAccountCreated
    case migrationRequired
  }

  init(
    appServices: AppServicesContainer,
    navigator: UINavigationController,
    inputMode: InputMode = .loggedOut,
    localLoginFlowViewModelFactory: LocalLoginFlowViewModel.Factory,
    completion: @escaping @MainActor (Result<SessionServicesContainer, Error>) -> Void
  ) {
    self.navigator = navigator
    self.appServices = appServices
    self.completion = completion
    self.inputMode = inputMode
    self.localLoginFlowViewModelFactory = localLoginFlowViewModelFactory
  }

  func start() {
    switch inputMode {
    case .loggedOut:
      guard let rawLogin: String = try? appServices.sessionContainer.fetchCurrentLogin()?.email
      else {
        completion(.failure(AuthError.noUserConnected(details: "rl1")))
        return
      }
      let login = Login(rawLogin)
      connect(with: login)
    case let .servicesLoaded(sessionServicesContainer):
      connect(with: sessionServicesContainer.session.login)
    }
  }

  private func makeLoginHandler(for login: Login) -> LoginStateMachine {
    let cryptoEngineProvider = SessionCryptoEngineProvider(logger: appServices.rootLogger)
    return LoginStateMachine(
      sessionsContainer: appServices.sessionContainer,
      appApiClient: appServices.appAPIClient,
      nitroAPIClient: appServices.nitroClient,
      deviceInfo: DeviceInfo.default,
      logger: appServices.rootLogger[.session],
      cryptoEngineProvider: cryptoEngineProvider,
      keychainService: appServices.keychainService,
      loginSettingsProvider: appServices,
      sessionCleaner: appServices.sessionCleaner,
      activityReporter: appServices.activityReporter,
      remoteLogger: appServices.remoteLogger)
  }

  private func connect(with login: Login) {
    guard let deviceId = appServices.appSettings.deviceId else {
      fatalError("Device Id Not available")
    }
    let loginHandler = makeLoginHandler(for: login)

    do {
      let handler = try loginHandler.createLocalLoginStateMachine(
        using: login, deviceId: deviceId, checkIsBiometricSetIntact: false)
      self.displayLocalLogin(using: handler)

    } catch {
      self.handle(error)
    }
  }

  private func displayLocalLogin(using loginHandler: LocalLoginStateMachine) {
    guard
      let userSecuritySettings = try? appServices.settingsManager.fetchOrCreateUserSettings(
        for: loginHandler.login)
    else {
      fatalError("Could not get user security settings")
    }

    guard
      let userSettings = try? appServices.settingsManager.fetchOrCreateSettings(
        for: loginHandler.login)
    else {
      fatalError("Could not get user settings")
    }

    let resetMasterPasswordService = ResetMasterPasswordService(
      login: loginHandler.login, settings: userSettings,
      keychainService: appServices.keychainService)

    let model = localLoginFlowViewModelFactory.make(
      stateMachine: loginHandler,
      resetMasterPasswordService: resetMasterPasswordService,
      userSettings: userSecuritySettings,
      login: loginHandler.login,
      context: .autofillExtension(cancelAction: { [weak self] in
        self?.cancelAction()
      })
    ) { [weak self] completion in
      self?.handleLoginCompletion(completion)
    }
    navigator.viewControllers = [
      UIHostingController(rootView: LocalLoginFlow(viewModel: model).tint(.ds.accentColor))
    ]
  }

  private func handleLoginCompletion(
    _ completionType: Result<LocalLoginFlowViewModel.Completion, Error>
  ) {
    switch completionType {
    case .success(let completion):
      switch completion {
      case .logout, .cancel:
        self.handle(AuthError.userCanceledAuthentication)
      case let .completed(config, logInfo):
        if case let .servicesLoaded(sessionServicesContainer) = self.inputMode {
          sessionServicesContainer.activityReporter.logSuccessfulLocalLogin(logInfo)
          self.completion(.success(sessionServicesContainer))
          return
        }
        Task {
          do {
            let origin = SessionLoadingContext.LocalContextOrigin.regular(
              reportedLoginMode: logInfo.loginMode)
            let sessionServicesContainer = try await self.loadSession(
              config.session, context: .localLogin(origin, isRecoveryKeyUsed: false))
            sessionServicesContainer.activityReporter.logSuccessfulLocalLogin(logInfo)
            self.completion(.success(sessionServicesContainer))
          } catch {
            self.handle(error)
          }
        }
      case .migration:
        self.handle(AuthError.migrationRequired)
      }
    case .failure(let error):
      self.handle(error)
    }
  }

  func loadSession(_ session: Session, context: SessionLoadingContext) async throws
    -> SessionServicesContainer
  {
    let container = try await SessionServicesContainer(
      session: session, appServices: appServices, context: context)
    InMemoryUserSessionStore.shared = .init(container: container)
    return container
  }

  private func handle(_ error: Error) {
    self.completion(.failure(error))
  }

  private func cancelAction() {
    self.handle(AuthError.userCanceledAuthentication)
  }
}

extension ActivityReporterProtocol {
  fileprivate func logSuccessfulLocalLogin(_ logInfo: LoginFlowLogInfo) {
    report(
      UserEvent.Login(
        isBackupCode: logInfo.isBackupCode,
        isFirstLogin: false,
        mode: logInfo.loginMode,
        status: .success,
        verificationMode: logInfo.verificationMode))
  }
}

extension AppServicesContainer: LoginSettingsProvider {
  func makeSettings(for login: CoreTypes.Login) throws -> LoginSettings {
    try LoginSettingsImpl(
      login: login, settingsManager: settingsManager, keychainService: keychainService)
  }

}
