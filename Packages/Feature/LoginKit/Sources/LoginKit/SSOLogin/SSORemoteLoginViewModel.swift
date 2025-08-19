import CoreSession
import CoreTypes
import DashlaneAPI
import Foundation
import StateMachine
import SwiftTreats
import UserTrackingFoundation

@MainActor
public class SSORemoteLoginViewModel: StateMachineBasedObservableObject, LoginKitServicesInjecting {

  public enum CompletionType {
    case completed(RemoteLoginSession)
    case cancel
  }

  let ssoAuthenticationInfo: SSOAuthenticationInfo
  let ssoViewModelFactory: SSOViewModel.Factory
  let completion: Completion<SSORemoteLoginViewModel.CompletionType>

  @Published public var stateMachine: SSORemoteStateMachine
  @Published public var isPerformingEvent: Bool = false

  public init(
    ssoAuthenticationInfo: SSOAuthenticationInfo,
    stateMachine: SSORemoteStateMachine,
    ssoViewModelFactory: SSOViewModel.Factory,
    completion: @escaping Completion<SSORemoteLoginViewModel.CompletionType>
  ) {
    self.ssoAuthenticationInfo = ssoAuthenticationInfo
    self.ssoViewModelFactory = ssoViewModelFactory
    self.stateMachine = stateMachine
    self.completion = completion
  }

  public func update(
    for event: SSORemoteStateMachine.Event, from oldState: SSORemoteStateMachine.State,
    to newState: SSORemoteStateMachine.State
  ) async {
    switch (newState, event) {
    case (.waitingForUserInput, _): break
    case (let .completed(remoteLoginSession), _):
      self.completion(.success(.completed(remoteLoginSession)))
    case (let .failed(error), _):
      self.completion(.failure(error.underlyingError))
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
      ssoAuthenticationInfo: .mock(),
      stateMachine: .mock,
      ssoViewModelFactory: .init({ _, _ in
        .mock
      }),
      completion: { _ in })
  }
}
