import Combine
import CoreKeychain
import CoreNetworking
import CoreSession
import CoreSettings
import CoreUserTracking
import DashTypes
import DashlaneAPI
import Foundation

@MainActor
public class RegularRemoteLoginFlowViewModel: ObservableObject, LoginKitServicesInjecting {

  public enum CompletionType {
    case completed(RemoteLoginSession, LoginFlowLogInfo)
    case cancel
  }

  public enum Step {
    case verification(VerificationMethod)
    case masterPassword(_ loginKeys: LoginKeys)
    case sso(SSOAuthenticationInfo)
  }

  @Published
  var steps: [Step]

  let remoteLoginHandler: RegularRemoteLoginHandler
  let tokenPublisher: AnyPublisher<String, Never>
  let masterPasswordFactory: MasterPasswordRemoteViewModel.Factory
  let completion: @MainActor (Result<RegularRemoteLoginFlowViewModel.CompletionType, Error>) -> Void
  private let email: String
  private let settingsManager: LocalSettingsFactory
  private let keychainService: AuthenticationKeychainServiceProtocol
  private let activityReporter: ActivityReporterProtocol
  let sessionCryptoEngineProvider: CryptoEngineProvider
  private let deviceUnlinkingFactory: DeviceUnlinkingFlowViewModel.Factory
  private let appAPIClient: AppAPIClient
  private let sessionActivityReporterProvider: SessionActivityReporterProvider
  private let nitroClient: NitroAPIClient
  private let accountVerificationFlowModelFactory: AccountVerificationFlowModel.Factory
  private let ssoRemoteLoginViewModelFactory: SSORemoteLoginViewModel.Factory

  private var lastSuccessfulAuthenticationMode: Definition.Mode?
  var verificationMode: Definition.VerificationMode = .none
  var isBackupCode: Bool = false

  let logger: Logger

  var logInfo: LoginFlowLogInfo {
    .init(
      loginMode: lastSuccessfulAuthenticationMode ?? .masterPassword,
      verificationMode: verificationMode,
      isBackupCode: isBackupCode)
  }

  public init(
    remoteLoginHandler: RegularRemoteLoginHandler,
    settingsManager: LocalSettingsFactory,
    sessionCryptoEngineProvider: CryptoEngineProvider,
    activityReporter: ActivityReporterProtocol,
    logger: Logger,
    appAPIClient: AppAPIClient,
    keychainService: AuthenticationKeychainServiceProtocol,
    email: String,
    sessionActivityReporterProvider: SessionActivityReporterProvider,
    tokenPublisher: AnyPublisher<String, Never>,
    deviceUnlinkingFactory: DeviceUnlinkingFlowViewModel.Factory,
    masterPasswordFactory: MasterPasswordRemoteViewModel.Factory,
    nitroClient: NitroAPIClient,
    accountVerificationFlowModelFactory: AccountVerificationFlowModel.Factory,
    steps: [RegularRemoteLoginFlowViewModel.Step] = [],
    ssoRemoteLoginViewModelFactory: SSORemoteLoginViewModel.Factory,
    completion: @escaping @MainActor (Result<RegularRemoteLoginFlowViewModel.CompletionType, Error>)
      -> Void
  ) {
    self.remoteLoginHandler = remoteLoginHandler
    self.email = email
    self.appAPIClient = appAPIClient
    self.sessionCryptoEngineProvider = sessionCryptoEngineProvider
    self.deviceUnlinkingFactory = deviceUnlinkingFactory
    self.sessionActivityReporterProvider = sessionActivityReporterProvider
    self.masterPasswordFactory = masterPasswordFactory
    self.nitroClient = nitroClient
    self.activityReporter = activityReporter
    self.logger = logger[.session]
    self.completion = completion
    self.keychainService = keychainService
    self.settingsManager = settingsManager
    self.tokenPublisher = tokenPublisher
    self.steps = steps
    self.accountVerificationFlowModelFactory = accountVerificationFlowModelFactory
    self.ssoRemoteLoginViewModelFactory = ssoRemoteLoginViewModelFactory
    updateStep()
  }

  internal func updateStep() {
    switch remoteLoginHandler.step {
    case .validateByDeviceRegistrationMethod(let deviceRegistrationValidator):
      switch deviceRegistrationValidator {
      case .tokenByEmail:
        self.steps.append(.verification(.emailToken))
      case .thirdPartyOTP(let option):
        self.steps.append(.verification(.totp(option.pushType)))
      case .loginViaSSO(let validator):
        self.steps.append(.sso(validator))
      case .authenticator:
        self.steps.append(.verification(.authenticatorPush))
      }
    case .validateMasterPassword(let deviceRegistrationData):
      self.steps.append(
        .masterPassword(
          LoginKeys(
            remoteKey: deviceRegistrationData.masterPasswordRemoteKey,
            authTicket: deviceRegistrationData.authTicket)))
    case let .completed(remoteLoginSession):
      self.completion(.success(.completed(remoteLoginSession, logInfo)))
    }
  }

  func makeAccountVerificationFlowViewModel(method: VerificationMethod)
    -> AccountVerificationFlowModel
  {
    accountVerificationFlowModelFactory.make(
      login: Login(email), mode: .masterPassword, verificationMethod: method,
      deviceInfo: remoteLoginHandler.deviceInfo, debugTokenPublisher: tokenPublisher,
      completion: { [weak self] completion in

        guard let self = self else {
          return
        }
        Task {
          do {
            let (authTicket, isBackupCode) = try completion.get()
            try await self.remoteLoginHandler.registerDevice(withAuthTicket: authTicket)
            self.verificationMode = method.verificationMode
            self.isBackupCode = isBackupCode
            self.updateStep()
          } catch {
            self.completion(.failure(error))
          }
        }
      })
  }

  func makeSSOLoginViewModel(ssoAuthenticationInfo: SSOAuthenticationInfo)
    -> SSORemoteLoginViewModel
  {
    return ssoRemoteLoginViewModelFactory.make(
      ssoAuthenticationInfo: ssoAuthenticationInfo, deviceInfo: remoteLoginHandler.deviceInfo
    ) { result in
      Task { @MainActor in
        await self.handleSSOResult(result)
      }
    }
  }

  private func handleSSOResult(_ result: Result<SSORemoteLoginViewModel.CompletionType, Error>)
    async
  {
    lastSuccessfulAuthenticationMode = .sso
    verificationMode = .none
    do {
      let result = try result.get()
      switch result {
      case let .completed(ssoKeys, data):
        let remoteLoginSession = try await self.validateRemoteKey(
          ssoKeys, data: data, isRecoveryLogin: false)
        self.lastSuccessfulAuthenticationMode = .sso
        self.verificationMode = Definition.VerificationMode.none
        self.completion(.success(.completed(remoteLoginSession, logInfo)))
      case .cancel:
        self.completion(.success(.cancel))
      }
    } catch {
      self.activityReporter.report(
        UserEvent.Login(
          mode: .sso,
          status: .errorInvalidSso,
          verificationMode: Definition.VerificationMode.none))
      self.completion(.failure(error))
    }
  }
}

extension RegularRemoteLoginFlowViewModel {
  private func validateRemoteKey(
    _ ssoKeys: SSOKeys, data: DeviceRegistrationData, isRecoveryLogin: Bool
  ) async throws -> RemoteLoginSession {
    return try await remoteLoginHandler.validateMasterKey(
      .ssoKey(ssoKeys.ssoKey),
      login: Login(email),
      authTicket: ssoKeys.authTicket,
      remoteKey: ssoKeys.remoteKey,
      data: data,
      isRecoveryLogin: isRecoveryLogin)
  }

  static func mock() -> RegularRemoteLoginFlowViewModel {
    return RegularRemoteLoginFlowViewModel(
      remoteLoginHandler: RegularRemoteLoginHandler.mock,
      settingsManager: LocalSettingsFactoryMock.mock,
      sessionCryptoEngineProvider: SessionCryptoEngineProvider(logger: LoggerMock()),
      activityReporter: .mock,
      logger: LoggerMock(),
      appAPIClient: .fake,
      keychainService: FakeAuthenticationKeychainService.mock,
      email: "",
      sessionActivityReporterProvider: .mock,
      tokenPublisher: PassthroughSubject().eraseToAnyPublisher(),
      deviceUnlinkingFactory: InjectedFactory {
        deviceUnlinker, login, _, purchasePlanFlowProvider, _, completion in
        DeviceUnlinkingFlowViewModel(
          deviceUnlinker: deviceUnlinker,
          login: login,
          authentication: ServerAuthentication(deviceAccessKey: "", deviceSecretKey: ""),
          logger: LoggerMock(),
          purchasePlanFlowProvider: purchasePlanFlowProvider,
          userTrackingSessionActivityReporter: .mock,
          completion: completion
        )
      },
      masterPasswordFactory: InjectedFactory { _, _, _, _, _, _, _ in
        return .mock
      },
      nitroClient: .fake,
      accountVerificationFlowModelFactory: .init { _, _, _, _, _, _ in
        AccountVerificationFlowModel.mock(verificationMethod: .emailToken)
      },
      steps: [.verification(.authenticatorPush)],
      ssoRemoteLoginViewModelFactory: .init({ _, _, _ in
        .mock
      })
    ) { _ in }
  }
}

extension VerificationMethod {
  fileprivate var verificationMode: Definition.VerificationMode {
    switch self {
    case .authenticatorPush:
      return .authenticatorApp
    case .emailToken:
      return .emailToken
    case .totp:
      return .otp2
    }
  }
}
