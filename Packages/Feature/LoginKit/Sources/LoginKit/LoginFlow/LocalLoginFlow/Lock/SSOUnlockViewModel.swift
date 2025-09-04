import CoreLocalization
import CoreSession
import CoreTypes
import DashlaneAPI
import Foundation
import StateMachine
import SwiftTreats
import UserTrackingFoundation

@MainActor
public class SSOUnlockViewModel: StateMachineBasedObservableObject, LoginKitServicesInjecting {

  public enum CompletionType {
    case completed(SSOKeys)
    case cancel
    case logout
  }

  enum ViewState {
    case ssoLogin(SSOLocalStateMachine.State, SSOAuthenticationInfo, _ deviceAccessKey: String)
    case inProgress
  }

  let login: Login
  let activityReporter: ActivityReporterProtocol
  let ssoLoginViewModelFactory: SSOLocalLoginViewModel.Factory
  let completion: Completion<SSOUnlockViewModel.CompletionType>

  @Published
  var viewState: ViewState?

  @Published
  var inProgress = false

  @Published
  var errorMessage: String?

  @Published public var isPerformingEvent: Bool = false

  @Published public var stateMachine: SSOUnlockStateMachine

  public init(
    login: Login,
    deviceAccessKey: String,
    stateMachine: SSOUnlockStateMachine,
    activityReporter: ActivityReporterProtocol,
    ssoLoginViewModelFactory: SSOLocalLoginViewModel.Factory,
    completion: @escaping Completion<SSOUnlockViewModel.CompletionType>
  ) {
    self.login = login
    self.activityReporter = activityReporter
    self.ssoLoginViewModelFactory = ssoLoginViewModelFactory
    self.completion = completion
    self.stateMachine = stateMachine
  }

  public func willPerform(_ event: SSOUnlockStateMachine.Event) async {
    switch event {
    case .ssoLogin:
      viewState = .inProgress
    case .logout, .cancel, .ssoLoginFailed, .ssoLoginCompleted:
      break
    }
  }

  public func update(
    for event: SSOUnlockStateMachine.Event, from oldState: SSOUnlockStateMachine.State,
    to newState: SSOUnlockStateMachine.State
  ) async {
    switch newState {

    case .locked:
      break
    case let .ssoLogin(initialState, ssoAuthenticationInfo, deviceAccessKey):
      self.viewState = .ssoLogin(initialState, ssoAuthenticationInfo, deviceAccessKey)
    case .logout:
      self.completion(.success(.logout))
    case let .failed(error):
      inProgress = false
      errorMessage = CoreL10n.errorMessage(for: error.underlyingError)
    case .cancelled:
      self.completion(.success(.cancel))
    case let .completed(ssoKeys):
      self.completion(.success(.completed(ssoKeys)))
    }
  }

  func unlock() {
    Task {
      await self.perform(.ssoLogin)
    }
  }

  func makeSSOLoginViewModel(
    initialState: SSOLocalStateMachine.State, ssoAuthenticationInfo: SSOAuthenticationInfo,
    deviceAccessKey: String
  ) -> SSOLocalLoginViewModel {
    return ssoLoginViewModelFactory.make(
      stateMachine: stateMachine.makeSSOLocalStateMachine(
        initialState: initialState, ssoAuthenticationInfo: ssoAuthenticationInfo),
      ssoAuthenticationInfo: ssoAuthenticationInfo
    ) { result in
      Task {
        switch result {
        case let .success(type):
          switch type {
          case .cancel:
            await self.perform(.cancel)
          case let .completed(ssoKeys):
            await self.perform(.ssoLoginCompleted(ssoKeys))
          }
        case let .failure(error):
          await self.perform(.ssoLoginFailed(StateMachineError(underlyingError: error)))
        }
      }

    }
  }

  func logout() async {
    await self.perform(.logout)
  }
}

extension SSOUnlockViewModel {
  static var mock: SSOUnlockViewModel {
    SSOUnlockViewModel(
      login: Login("_"), deviceAccessKey: "deviceAccessKey", stateMachine: .mock,
      activityReporter: .mock,
      ssoLoginViewModelFactory: .init({ _, _, _ in
        .mock
      }), completion: { _ in })
  }
}
