import Combine
import CoreKeychain
import CoreNetworking
import CoreSession
import CoreSettings
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import StateMachine
import UserTrackingFoundation

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
    case sso(SSOAuthenticationInfo)
  }

  @Published
  var steps: [Step]

  let login: Login
  let tokenPublisher: AnyPublisher<String, Never>
  let completion: @MainActor (Result<RegularRemoteLoginFlowViewModel.CompletionType, Error>) -> Void
  private let settingsManager: LocalSettingsFactory
  private let activityReporter: ActivityReporterProtocol
  private let accountVerificationFlowModelFactory: AccountVerificationFlowModel.Factory
  private let ssoRemoteLoginViewModelFactory: SSORemoteLoginViewModel.Factory
  private let masterPasswordRemoteLoginFlowModelFactory: MasterPasswordRemoteLoginFlowModel.Factory

  private var lastSuccessfulAuthenticationMode: Definition.Mode?

  let logger: Logger

  @Published public var stateMachine: RegularRemoteLoginStateMachine
  @Published public var isPerformingEvent: Bool = false

  public init(
    login: Login,
    deviceRegistrationMethod: LoginMethod,
    stateMachine: RegularRemoteLoginStateMachine,
    settingsManager: LocalSettingsFactory,
    activityReporter: ActivityReporterProtocol,
    logger: Logger,
    tokenPublisher: AnyPublisher<String, Never>,
    accountVerificationFlowModelFactory: AccountVerificationFlowModel.Factory,
    steps: [RegularRemoteLoginFlowViewModel.Step] = [],
    ssoRemoteLoginViewModelFactory: SSORemoteLoginViewModel.Factory,
    masterPasswordRemoteLoginFlowModelFactory: MasterPasswordRemoteLoginFlowModel.Factory,
    completion: @escaping @MainActor (Result<RegularRemoteLoginFlowViewModel.CompletionType, Error>)
      -> Void
  ) {
    self.login = login
    self.stateMachine = stateMachine
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
      self.completion(
        .success(
          .completed(
            remoteLoginSession,
            .init(
              loginMode: lastSuccessfulAuthenticationMode ?? .masterPassword,
              verificationMode: remoteLoginSession.verificationMethod?.verificationMode ?? .none,
              isBackupCode: remoteLoginSession.isBackupCode))))
    case let .ssoLoginFlow(initialStep, info):
      self.steps.append(.sso(info))
    case .initializing: break
    case let .failed(error):
      self.completion(.failure(error.underlyingError))
    case .cancelled:
      self.completion(.success(.cancel))
    }
  }

  func makeSSOLoginViewModel(ssoAuthenticationInfo: SSOAuthenticationInfo)
    -> SSORemoteLoginViewModel
  {
    return ssoRemoteLoginViewModelFactory.make(
      ssoAuthenticationInfo: ssoAuthenticationInfo,
      stateMachine: stateMachine.makeSSORemoteStateMachine(
        ssoAuthenticationInfo: ssoAuthenticationInfo)
    ) { result in
      Task { @MainActor in
        await self.handleSSOResult(result)
      }
    }
  }

  private func handleSSOResult(_ result: Result<SSORemoteLoginViewModel.CompletionType, Error>)
    async
  {
    do {
      let result = try result.get()
      switch result {
      case let .completed(remoteLoginSession):
        self.lastSuccessfulAuthenticationMode = .sso
        await self.perform(.ssoFlowDidFinish(remoteLoginSession))
      case .cancel:
        await self.perform(.cancel)
      }
    } catch {
      self.activityReporter.report(
        UserEvent.Login(
          mode: .sso,
          status: .errorInvalidSso,
          verificationMode: Definition.VerificationMode.none))
      await self.perform(.failed(StateMachineError(underlyingError: error)))
    }
  }

  func makeMasterPasswordRemoteLoginFlowModel(
    verificationMethod: VerificationMethod, deviceInfo: DeviceInfo
  ) -> MasterPasswordRemoteLoginFlowModel {
    masterPasswordRemoteLoginFlowModelFactory.make(
      login: login,
      deviceInfo: deviceInfo,
      verificationMethod: verificationMethod,
      stateMachine: stateMachine.makeMasterPasswordFlowRemoteStateMachine(
        state: .initialize, verificationMethod: verificationMethod),
      tokenPublisher: tokenPublisher
    ) { result in
      Task {
        do {
          let result = try result.get()
          switch result {
          case let .completed(remoteLoginSession):
            await self.perform(.masterPasswordFlowDidFinish(remoteLoginSession))
          case .cancel:
            await self.perform(.cancel)
          }
        } catch {
          await self.perform(.failed(StateMachineError(underlyingError: error)))
        }
      }

    }
  }
}

extension RegularRemoteLoginFlowViewModel {
  static func mock() -> RegularRemoteLoginFlowViewModel {
    return RegularRemoteLoginFlowViewModel(
      login: Login("_"),
      deviceRegistrationMethod: .tokenByEmail([]),
      stateMachine: .mock,
      settingsManager: LocalSettingsFactoryMock.mock,
      activityReporter: .mock,
      logger: .mock,
      tokenPublisher: PassthroughSubject().eraseToAnyPublisher(),
      accountVerificationFlowModelFactory: .init { _, _, _, _, _ in
        AccountVerificationFlowModel.mock(verificationMethod: .emailToken)
      },
      steps: [.masterPassword(.accountVerification(.emailToken, .mock), .emailToken, .mock)],
      ssoRemoteLoginViewModelFactory: .init({ _, _, _ in
        .mock
      }),
      masterPasswordRemoteLoginFlowModelFactory: .init({ _, _, _, _, _, _ in
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
