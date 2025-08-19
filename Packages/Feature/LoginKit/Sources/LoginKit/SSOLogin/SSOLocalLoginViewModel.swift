import CoreSession
import CoreTypes
import DashlaneAPI
import Foundation
import StateMachine
import SwiftTreats
import UserTrackingFoundation

@MainActor
public class SSOLocalLoginViewModel: StateMachineBasedObservableObject, LoginKitServicesInjecting {
  public enum CompletionType {
    case completed(SSOKeys)
    case cancel
  }

  let ssoAuthenticationInfo: SSOAuthenticationInfo
  let ssoViewModelFactory: SSOViewModel.Factory
  let completion: Completion<SSOLocalLoginViewModel.CompletionType>

  @Published public var stateMachine: SSOLocalStateMachine
  @Published public var isPerformingEvent: Bool = false

  public init(
    stateMachine: SSOLocalStateMachine,
    ssoAuthenticationInfo: SSOAuthenticationInfo,
    ssoViewModelFactory: SSOViewModel.Factory,
    completion: @escaping Completion<SSOLocalLoginViewModel.CompletionType>
  ) {
    self.ssoAuthenticationInfo = ssoAuthenticationInfo
    self.ssoViewModelFactory = ssoViewModelFactory
    self.stateMachine = stateMachine
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
      stateMachine: .mock,
      ssoAuthenticationInfo: .mock(),
      ssoViewModelFactory: .init({ _, _ in
        .mock
      }),
      completion: { _ in })
  }
}
