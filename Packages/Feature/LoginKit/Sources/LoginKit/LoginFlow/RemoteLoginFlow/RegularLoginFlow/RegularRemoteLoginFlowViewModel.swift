import Combine
import CoreKeychain
import CoreNetworking
import CoreSession
import CoreSettings
import CoreUserTracking
import DashTypes
import DashlaneAPI
import Foundation
import StateMachine

@MainActor
public class RegularRemoteLoginFlowViewModel: StateMachineBasedObservableObject,
  LoginKitServicesInjecting
{

  public enum CompletionType {
    case completed(RemoteLoginSession, LoginFlowLogInfo)
    case cancel
  }

  public enum Step {
    case masterPassword(MasterPasswordFlowRemoteStateMachine.State, VerificationMethod, DeviceInfo)
    case sso(SSOAuthenticationInfo, DeviceInfo)
  }

  @Published
  var steps: [Step]

  let login: Login
  let tokenPublisher: AnyPublisher<String, Never>
  let completion: @MainActor (Result<RegularRemoteLoginFlowViewModel.CompletionType, Error>) -> Void
  private let settingsManager: LocalSettingsFactory
  private let activityReporter: ActivityReporterProtocol
  private let deviceUnlinkingFactory: DeviceUnlinkingFlowViewModel.Factory
  private let accountVerificationFlowModelFactory: AccountVerificationFlowModel.Factory
  private let ssoRemoteLoginViewModelFactory: SSORemoteLoginViewModel.Factory
  private let masterPasswordRemoteLoginFlowModelFactory: MasterPasswordRemoteLoginFlowModel.Factory

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

  public var stateMachine: RegularRemoteLoginStateMachine

  public init(
    login: Login,
    deviceRegistrationMethod: LoginMethod,
    deviceInfo: DeviceInfo,
    settingsManager: LocalSettingsFactory,
    activityReporter: ActivityReporterProtocol,
    logger: Logger,
    tokenPublisher: AnyPublisher<String, Never>,
    deviceUnlinkingFactory: DeviceUnlinkingFlowViewModel.Factory,
    accountVerificationFlowModelFactory: AccountVerificationFlowModel.Factory,
    steps: [RegularRemoteLoginFlowViewModel.Step] = [],
    regularRemoteLoginStateMachineFactory: RegularRemoteLoginStateMachine.Factory,
    ssoRemoteLoginViewModelFactory: SSORemoteLoginViewModel.Factory,
    masterPasswordRemoteLoginFlowModelFactory: MasterPasswordRemoteLoginFlowModel.Factory,
    completion: @escaping @MainActor (Result<RegularRemoteLoginFlowViewModel.CompletionType, Error>)
      -> Void
  ) {
    self.login = login
    self.stateMachine = regularRemoteLoginStateMachineFactory.make(
      login: login, deviceRegistrationMethod: deviceRegistrationMethod, deviceInfo: deviceInfo)
    self.deviceUnlinkingFactory = deviceUnlinkingFactory
    self.activityReporter = activityReporter
    self.logger = logger[.session]
    self.completion = completion
    self.settingsManager = settingsManager
    self.tokenPublisher = tokenPublisher
    self.steps = steps
    self.accountVerificationFlowModelFactory = accountVerificationFlowModelFactory
    self.ssoRemoteLoginViewModelFactory = ssoRemoteLoginViewModelFactory
    self.masterPasswordRemoteLoginFlowModelFactory = masterPasswordRemoteLoginFlowModelFactory
    Task {
      await self.perform(.initialize)
    }
  }

  public func update(
    for event: RegularRemoteLoginStateMachine.Event,
    from oldState: RegularRemoteLoginStateMachine.State,
    to newState: RegularRemoteLoginStateMachine.State
  ) async {
    switch newState {
    case let .masterPasswordFlow(state, verificationMethod, deviceInfo):
      self.steps.append(.masterPassword(state, verificationMethod, deviceInfo))
    case let .completed(remoteLoginSession):
      self.completion(.success(.completed(remoteLoginSession, logInfo)))
    case let .ssoLoginFlow(initialStep, info, deviceInfo):
      self.steps.append(.sso(info, deviceInfo))
    case .initializing: break
    case .failed:
      self.completion(.failure(AccountError.unknown))
    case .cancelled:
      self.completion(.success(.cancel))
    }
  }

  func makeSSOLoginViewModel(ssoAuthenticationInfo: SSOAuthenticationInfo, deviceInfo: DeviceInfo)
    -> SSORemoteLoginViewModel
  {
    return ssoRemoteLoginViewModelFactory.make(
      ssoAuthenticationInfo: ssoAuthenticationInfo, deviceInfo: deviceInfo
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
      case let .completed(remoteLoginSession):
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

  func makeMasterPasswordRemoteLoginFlowModel(
    verificationMethod: VerificationMethod, deviceInfo: DeviceInfo
  ) -> MasterPasswordRemoteLoginFlowModel {
    masterPasswordRemoteLoginFlowModelFactory.make(
      login: login, deviceInfo: deviceInfo, verificationMethod: verificationMethod,
      tokenPublisher: tokenPublisher
    ) { result in
      do {
        let result = try result.get()
        switch result {
        case let .completed(remoteLoginSession, logInfo):
          self.completion(.success(.completed(remoteLoginSession, logInfo)))
        case .cancel:
          self.completion(.success(.cancel))
        }
      } catch {

      }
    }
  }
}

extension RegularRemoteLoginFlowViewModel {
  static func mock() -> RegularRemoteLoginFlowViewModel {
    return RegularRemoteLoginFlowViewModel(
      login: Login("_"),
      deviceRegistrationMethod: .tokenByEmail([]),
      deviceInfo: .mock,
      settingsManager: LocalSettingsFactoryMock.mock,
      activityReporter: .mock,
      logger: LoggerMock(),
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
      accountVerificationFlowModelFactory: .init { _, _, _, _, _, _ in
        AccountVerificationFlowModel.mock(verificationMethod: .emailToken)
      },
      steps: [.masterPassword(.accountVerification(.emailToken, .mock), .emailToken, .mock)],
      regularRemoteLoginStateMachineFactory: .init({ _, _, _, _ in
        .mock
      }),
      ssoRemoteLoginViewModelFactory: .init({ _, _, _ in
        .mock
      }),
      masterPasswordRemoteLoginFlowModelFactory: .init({ _, _, _, _, _ in
        .mock
      })
    ) { _ in }
  }
}

extension VerificationMethod {
  var verificationMode: Definition.VerificationMode {
    switch self {
    case .emailToken:
      return .emailToken
    case .totp:
      return .otp2
    }
  }
}
