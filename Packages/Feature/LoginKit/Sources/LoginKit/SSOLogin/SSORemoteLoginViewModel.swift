import CoreSession
import DashTypes
import DashlaneAPI
import Foundation
import StateMachine
import SwiftTreats

@MainActor
public class SSORemoteLoginViewModel: StateMachineBasedObservableObject, LoginKitServicesInjecting {

  public enum CompletionType {
    case completed(SSOKeys, DeviceRegistrationData)
    case cancel
  }

  let ssoAuthenticationInfo: SSOAuthenticationInfo
  let ssoViewModelFactory: SSOViewModel.Factory
  let completion: Completion<SSORemoteLoginViewModel.CompletionType>

  public var stateMachine: SSORemoteStateMachine

  public init(
    ssoAuthenticationInfo: SSOAuthenticationInfo,
    deviceInfo: DeviceInfo,
    ssoViewModelFactory: SSOViewModel.Factory,
    ssoRemoteStateMachineFactory: SSORemoteStateMachine.Factory,
    completion: @escaping Completion<SSORemoteLoginViewModel.CompletionType>
  ) {
    self.ssoAuthenticationInfo = ssoAuthenticationInfo
    self.ssoViewModelFactory = ssoViewModelFactory
    stateMachine = ssoRemoteStateMachineFactory.make(
      ssoAuthenticationInfo: ssoAuthenticationInfo, deviceInfo: deviceInfo)
    self.completion = completion
  }

  public func update(
    for event: SSORemoteStateMachine.Event, from oldState: SSORemoteStateMachine.State,
    to newState: SSORemoteStateMachine.State
  ) async {
    switch (newState, event) {
    case (.waitingForUserInput, _): break
    case (let .receivedSSOKeys(ssoKeys, deviceRegistrationData), _):
      self.completion(.success(.completed(ssoKeys, deviceRegistrationData)))
    case (.failed, _):
      self.completion(.failure(SSOAccountError.invalidServiceProviderKey))
    case (.cancelled, _):
      self.completion(.success(.cancel))
    }
  }

  func makeSSOViewModel() -> SSOViewModel {
    ssoViewModelFactory.make(ssoAuthenticationInfo: ssoAuthenticationInfo) { [weak self] result in
      guard let self = self else {
        return
      }
      Task {
        await self.perform(.receivedSSOCallback(result))
      }
    }
  }
}

extension SSORemoteLoginViewModel {
  static var mock: SSORemoteLoginViewModel {
    SSORemoteLoginViewModel(
      ssoAuthenticationInfo: .mock(), deviceInfo: .mock,
      ssoViewModelFactory: .init({ _, _ in
        .mock
      }),
      ssoRemoteStateMachineFactory: .init({ ssoAuthenticationInfo, deviceInfo in
        .init(
          ssoAuthenticationInfo: ssoAuthenticationInfo, deviceInfo: deviceInfo,
          apiClient: .mock({}),
          cryptoEngineProvider: SessionCryptoEngineProvider(logger: LoggerMock()),
          logger: LoggerMock())
      }), completion: { _ in })
  }
}
