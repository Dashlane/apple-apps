import Combine
import CoreSession
import CoreTypes
import Foundation
import StateMachine
import SwiftTreats
import UserTrackingFoundation

@MainActor
public class MasterPasswordRemoteLoginFlowModel: StateMachineBasedObservableObject,
  LoginKitServicesInjecting
{

  public enum CompletionType {
    case completed(RemoteLoginSession)
    case cancel
  }

  public enum Step {
    case verification(VerificationMethod, DeviceInfo)
    case masterPassword(MasterPasswordInputRemoteStateMachine.State, DeviceRegistrationData)
  }

  @Published
  var steps: [Step] = []

  private let login: Login
  private let accountVerificationFlowModelFactory: AccountVerificationFlowModel.Factory
  private var tokenPublisher: AnyPublisher<String, Never>
  @Published public var stateMachine: MasterPasswordFlowRemoteStateMachine
  @Published public var isPerformingEvent: Bool = false
  private let masterPasswordFactory: MasterPasswordInputRemoteViewModel.Factory
  private let completion:
    @MainActor (Result<MasterPasswordRemoteLoginFlowModel.CompletionType, Error>) -> Void

  public init(
    login: Login,
    deviceInfo: DeviceInfo,
    verificationMethod: VerificationMethod,
    stateMachine: MasterPasswordFlowRemoteStateMachine,
    tokenPublisher: AnyPublisher<String, Never>,
    accountVerificationFlowModelFactory: AccountVerificationFlowModel.Factory,
    masterPasswordFactory: MasterPasswordInputRemoteViewModel.Factory,
    completion: @escaping @MainActor (
      Result<MasterPasswordRemoteLoginFlowModel.CompletionType, Error>
    ) -> Void
  ) {
    self.login = login
    self.accountVerificationFlowModelFactory = accountVerificationFlowModelFactory
    self.masterPasswordFactory = masterPasswordFactory
    self.tokenPublisher = tokenPublisher
    self.completion = completion
    self.stateMachine = stateMachine
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
      self.completion(.success(.completed(remoteLoginSession)))
    }
  }
}

extension MasterPasswordRemoteLoginFlowModel {
  func makeAccountVerificationFlowViewModel(method: VerificationMethod, deviceInfo: DeviceInfo)
    -> AccountVerificationFlowModel
  {
    accountVerificationFlowModelFactory.make(
      login: login, mode: .masterPassword,
      stateMachine: stateMachine.makeAccountVerificationStateMachine(verificationMethod: method),
      debugTokenPublisher: tokenPublisher,
      completion: { [weak self] completion in

        guard let self = self else {
          return
        }
        Task {
          do {
            let (authTicket, isBackupCode) = try completion.get()
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
    state: MasterPasswordInputRemoteStateMachine.State, data: DeviceRegistrationData
  ) -> MasterPasswordInputRemoteViewModel {
    masterPasswordFactory.make(
      stateMachine: stateMachine.makeMasterPasswordInputRemoteStateMachine(
        state: state, data: data),
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
      login: Login(""), deviceInfo: .mock, verificationMethod: .emailToken, stateMachine: .mock,
      tokenPublisher: Just("").eraseToAnyPublisher(),
      accountVerificationFlowModelFactory: .init({ _, _, _, _, _ in
        .mock(verificationMethod: .emailToken)
      }),
      masterPasswordFactory: .init({ _, _, _, _ in
        .mock
      }), completion: { _ in })
  }
}
