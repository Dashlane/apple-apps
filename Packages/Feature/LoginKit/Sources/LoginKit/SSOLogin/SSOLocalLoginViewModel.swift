import CoreSession
import DashTypes
import DashlaneAPI
import Foundation
import StateMachine
import SwiftTreats

@MainActor
public class SSOLocalLoginViewModel: StateMachineBasedObservableObject, LoginKitServicesInjecting {

  public enum CompletionType {
    case completed(SSOKeys)
    case cancel
  }

  let ssoAuthenticationInfo: SSOAuthenticationInfo
  let ssoViewModelFactory: SSOViewModel.Factory
  let completion: Completion<SSOLocalLoginViewModel.CompletionType>

  public var stateMachine: SSOLocalStateMachine

  public init(
    deviceAccessKey: String,
    ssoAuthenticationInfo: SSOAuthenticationInfo,
    ssoViewModelFactory: SSOViewModel.Factory,
    ssoLocalStateMachineFactory: SSOLocalStateMachine.Factory,
    completion: @escaping Completion<SSOLocalLoginViewModel.CompletionType>
  ) {
    self.ssoAuthenticationInfo = ssoAuthenticationInfo
    self.ssoViewModelFactory = ssoViewModelFactory
    stateMachine = ssoLocalStateMachineFactory.make(
      ssoAuthenticationInfo: ssoAuthenticationInfo, deviceAccessKey: deviceAccessKey)
    self.completion = completion
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

  public func update(
    for event: SSOLocalStateMachine.Event, from oldState: SSOLocalStateMachine.State,
    to newState: SSOLocalStateMachine.State
  ) async {
    switch (newState, event) {
    case (.waitingForUserInput, _): break
    case (let .receivedSSOKeys(ssoKeys), _):
      self.completion(.success((.completed(ssoKeys))))
    case (.failed, _):
      self.completion(.failure(SSOAccountError.invalidServiceProviderKey))
    case (.cancelled, _):
      self.completion(.success(.cancel))
    }
  }
}

extension SSOLocalLoginViewModel {
  static var mock: SSOLocalLoginViewModel {
    SSOLocalLoginViewModel(
      deviceAccessKey: "",
      ssoAuthenticationInfo: .mock(),
      ssoViewModelFactory: .init({ _, _ in
        .mock
      }),
      ssoLocalStateMachineFactory: .init({ _, deviceAccessKey in
        .init(
          ssoAuthenticationInfo: .mock(), deviceAccessKey: deviceAccessKey, apiClient: .fake,
          cryptoEngineProvider: SessionCryptoEngineProvider(logger: LoggerMock()),
          logger: LoggerMock())
      }),
      completion: { _ in })
  }
}
