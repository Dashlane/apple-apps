import Combine
import CoreKeychain
import CoreLocalization
import CoreNetworking
import CoreSession
import CoreSettings
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import Logger
import SwiftTreats
import UIDelight
import UserTrackingFoundation

@MainActor
public class LoginFlowViewModel: ObservableObject, LoginKitServicesInjecting {

  enum Step {
    case loginInput(_ email: String? = nil)
    case login(CoreSession.LoginType)
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

  let loginHandler: LoginStateMachine
  let completion: (Completion) -> Void
  let login: Login?
  let deviceId: String?
  private let tokenPublisher: AnyPublisher<String, Never>
  private let localLoginViewModelFactory: LocalLoginFlowViewModel.Factory
  private let remoteLoginViewModelFactory: RemoteLoginFlowViewModel.Factory
  private let loginViewModelFactory: LoginInputViewModel.Factory
  private let spiegelSettingsManager: LocalSettingsFactory
  private let keychainService: AuthenticationKeychainServiceProtocol
  private let cryptoEngineProvider: CryptoEngineProvider
  private let sessionLogger: Logger
  private let purchasePlanFlowProvider: PurchasePlanFlowProvider
  private let sessionActivityReporterProvider: SessionActivityReporterProvider
  private let context: UnlockOriginProcess

  public init(
    login: Login?,
    deviceId: String?,
    logger: Logger,
    loginHandler: LoginStateMachine,
    keychainService: AuthenticationKeychainServiceProtocol,
    cryptoEngineProvider: CryptoEngineProvider,
    spiegelSettingsManager: LocalSettingsFactory,
    localLoginViewModelFactory: LocalLoginFlowViewModel.Factory,
    remoteLoginViewModelFactory: RemoteLoginFlowViewModel.Factory,
    loginViewModelFactory: LoginInputViewModel.Factory,
    purchasePlanFlowProvider: PurchasePlanFlowProvider,
    sessionActivityReporterProvider: SessionActivityReporterProvider,
    tokenPublisher: AnyPublisher<String, Never>,
    context: UnlockOriginProcess,
    completion: @escaping (LoginFlowViewModel.Completion) -> Void
  ) {
    self.deviceId = deviceId
    self.sessionLogger = logger[.session]
    self.tokenPublisher = tokenPublisher
    self.purchasePlanFlowProvider = purchasePlanFlowProvider
    self.sessionActivityReporterProvider = sessionActivityReporterProvider
    self.keychainService = keychainService
    self.cryptoEngineProvider = cryptoEngineProvider
    self.loginViewModelFactory = loginViewModelFactory
    self.remoteLoginViewModelFactory = remoteLoginViewModelFactory
    self.localLoginViewModelFactory = localLoginViewModelFactory
    self.loginHandler = loginHandler
    self.spiegelSettingsManager = spiegelSettingsManager
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

  func makeLoginViewModel(email: String? = nil) -> LoginInputViewModel {
    loginViewModelFactory.make(
      email: email,
      loginHandler: loginHandler,
      staticErrorPublisher: self.$staticErrorPublisher.eraseToAnyPublisher()
    ) { [weak self] result in
      guard let self = self else { return }
      self.connect(using: result)
    }
  }

  func connect(using loginResult: LoginStateMachine.LoginResult?) {
    guard let result = loginResult else {
      completion(.logout)
      return
    }
    switch result {
    case let .localLoginRequired(localLoginStateMachine):
      self.steps.append(.login(.localLogin(localLoginStateMachine)))
    case let .remoteLoginRequired(login, method, deviceInfo):
      self.steps.append(
        .login(.remoteLogin(.regularRemoteLogin(login, deviceRegistrationMethod: method))))
    case let .ssoAccountCreation(login, info):
      completion(.ssoAccountCreation(login, info))
    case let .deviceToDeviceRemoteLogin(login, deviceInfo):
      self.steps.append(
        .login(.remoteLogin(.deviceToDeviceRemoteLogin(login, deviceInfo: deviceInfo))))
    }
  }

  private func localLogin(with login: Login) async throws {
    guard let deviceId = deviceId else {
      fatalError("Device Id Not available")
    }

    let handler = try loginHandler.createLocalLoginStateMachine(using: login, deviceId: deviceId)
    self.steps
      .append(contentsOf: [
        .loginInput(login.email),
        .login(.localLogin(handler)),
      ])
  }
}

extension LoginFlowViewModel {
  func makeLocalLoginFlowViewModel(using loginHandler: LocalLoginStateMachine)
    -> LocalLoginFlowViewModel
  {
    guard
      let userSecuritySettings = try? spiegelSettingsManager.fetchOrCreateUserSettings(
        for: loginHandler.login)
    else {
      fatalError("Could not get user security settings")
    }

    guard
      let userSettings = try? spiegelSettingsManager.fetchOrCreateSettings(for: loginHandler.login)
    else {
      fatalError("Could not get user settings")
    }

    let resetMasterPasswordService = ResetMasterPasswordService(
      login: loginHandler.login, settings: userSettings, keychainService: keychainService)

    return localLoginViewModelFactory.make(
      stateMachine: loginHandler, resetMasterPasswordService: resetMasterPasswordService,
      userSettings: userSecuritySettings, login: loginHandler.login, context: context
    ) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case let .success(completion):
        if case .cancel = completion {
          _ = self.steps.popLast()
          return
        }
        self.completion(.localLogin(completion))
      case let .failure(error):
        self.handle(error: error)
      }
    }
  }

  func handle(error: Error) {
    switch error {
    case let error as DashlaneAPI.APIError where error.hasAuthenticationCode(.invalidOTPBlocked):
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
    remoteLoginViewModelFactory.make(
      type: type,
      deviceInfo: loginHandler.deviceInfo,
      stateMachine: loginHandler.makeRemoteLoginStateMachine(type: type),
      purchasePlanFlowProvider: purchasePlanFlowProvider,
      sessionActivityReporterProvider: sessionActivityReporterProvider,
      tokenPublisher: tokenPublisher
    ) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case let .success(completion):
        if case .dismiss = completion {
          _ = self.steps.popLast()
          return
        }
        self.completion(.remoteLogin(completion))
      case let .failure(error):
        self.handle(error: error)
      }
    }
  }
}
