import Combine
import CoreSession
import CoreUserTracking
import DashTypes
import Foundation
import StateMachine
import SwiftTreats

@MainActor
public class MasterPasswordRemoteLoginFlowModel: StateMachineBasedObservableObject,
  LoginKitServicesInjecting
{

  public enum Step {
    case verification(VerificationMethod, DeviceInfo)
    case masterPassword(MasterPasswordRemoteStateMachine.State, DeviceRegistrationData)
  }

  @Published
  var steps: [Step] = []

  private let login: Login
  private let accountVerificationFlowModelFactory: AccountVerificationFlowModel.Factory
  private var tokenPublisher: AnyPublisher<String, Never>
  var verificationMode: Definition.VerificationMode = .none
  public var stateMachine: MasterPasswordFlowRemoteStateMachine
  private let masterPasswordFactory: MasterPasswordInputRemoteViewModel.Factory
  private let completion:
    @MainActor (Result<RegularRemoteLoginFlowViewModel.CompletionType, Error>) -> Void

  public init(
    login: Login,
    deviceInfo: DeviceInfo,
    verificationMethod: VerificationMethod,
    tokenPublisher: AnyPublisher<String, Never>,
    accountVerificationFlowModelFactory: AccountVerificationFlowModel.Factory,
    masterPasswordFactory: MasterPasswordInputRemoteViewModel.Factory,
    masterPasswordRemoteStateMachineFactory: MasterPasswordFlowRemoteStateMachine.Factory,
    completion: @escaping @MainActor (Result<RegularRemoteLoginFlowViewModel.CompletionType, Error>)
      -> Void
  ) {
    self.login = login
    self.accountVerificationFlowModelFactory = accountVerificationFlowModelFactory
    self.masterPasswordFactory = masterPasswordFactory
    self.tokenPublisher = tokenPublisher
    self.completion = completion
    self.stateMachine = masterPasswordRemoteStateMachineFactory.make(
      state: .initialize, verificationMethod: verificationMethod, deviceInfo: deviceInfo,
      login: login)
    Task {
      await perform(.initialize)
    }
  }

  public func update(
    for event: MasterPasswordFlowRemoteStateMachine.Event,
    from oldState: MasterPasswordFlowRemoteStateMachine.State,
    to newState: MasterPasswordFlowRemoteStateMachine.State
  ) async {
    switch state {
    case .initialize: break
    case let .accountVerification(verificationMethod, deviceInfo):
      self.steps.append(.verification(verificationMethod, deviceInfo))
    case let .masterPasswordValidation(state, data):
      self.steps.append(.masterPassword(state, data))
    case .failed:
      self.completion(.failure(AccountError.unknown))
    case let .masterPasswordValidated(remoteLoginSession):
      self.completion(
        .success(.completed(remoteLoginSession, LoginFlowLogInfo(loginMode: .masterPassword))))
    }
  }
}

extension MasterPasswordRemoteLoginFlowModel {
  func makeAccountVerificationFlowViewModel(method: VerificationMethod, deviceInfo: DeviceInfo)
    -> AccountVerificationFlowModel
  {
    accountVerificationFlowModelFactory.make(
      login: login, mode: .masterPassword, verificationMethod: method, deviceInfo: deviceInfo,
      debugTokenPublisher: tokenPublisher,
      completion: { [weak self] completion in

        guard let self = self else {
          return
        }
        Task {
          do {
            let (authTicket, isBackupCode) = try completion.get()
            self.verificationMode = method.verificationMode
            await self.perform(
              .accountVerificationDidFinish(authTicket, isBackupCode: isBackupCode, method))
          } catch {
            await self.perform(
              .accountVerificationFailed(StateMachineError(underlyingError: error)))
          }
        }
      })
  }

  func makeMasterPasswordInputRemoteViewModel(
    state: MasterPasswordRemoteStateMachine.State, data: DeviceRegistrationData
  ) -> MasterPasswordInputRemoteViewModel {
    masterPasswordFactory.make(
      state: state,
      login: login,
      data: data
    ) { [weak self] remoteLoginSession in
      guard let self = self else {
        return
      }
      Task {
        await self.perform(.masterPasswordValidated(remoteLoginSession))
      }
    }
  }
}

extension MasterPasswordRemoteLoginFlowModel {
  static var mock: MasterPasswordRemoteLoginFlowModel {
    MasterPasswordRemoteLoginFlowModel(
      login: Login(""), deviceInfo: .mock, verificationMethod: .emailToken,
      tokenPublisher: Just("").eraseToAnyPublisher(),
      accountVerificationFlowModelFactory: .init({ _, _, verificationMethod, _, _, _ in
        .mock(verificationMethod: verificationMethod)
      }),
      masterPasswordFactory: .init({ _, _, _, _ in
        .mock
      }),
      masterPasswordRemoteStateMachineFactory: .init({ _, _, _, _ in
        .mock
      }), completion: { _ in })
  }
}
