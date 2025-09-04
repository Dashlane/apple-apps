import Combine
import CoreNetworking
import CoreSession
import CoreTypes
import DashlaneAPI
import Foundation
import StateMachine
import SwiftTreats
import UserTrackingFoundation

@MainActor
public class AccountVerificationFlowModel: StateMachineBasedObservableObject,
  LoginKitServicesInjecting
{

  enum ViewState: Equatable {
    case initializing
    case emailToken
    case totp(hasDUOPush: Bool)
  }

  @Published
  var viewState: ViewState = .initializing

  private let login: Login
  private let mode: Definition.Mode
  private let tokenVerificationViewModelFactory: TokenVerificationViewModel.Factory
  private let debugTokenPublisher: AnyPublisher<String, Never>?
  private let totpVerificationViewModelFactory: TOTPVerificationViewModel.Factory
  private let completion: @MainActor (Result<(AuthTicket, Bool), Error>) -> Void
  @Published public var stateMachine: AccountVerificationStateMachine
  @Published public var isPerformingEvent: Bool = false

  public init(
    login: Login,
    mode: Definition.Mode,
    stateMachine: AccountVerificationStateMachine,
    debugTokenPublisher: AnyPublisher<String, Never>? = nil,
    tokenVerificationViewModelFactory: TokenVerificationViewModel.Factory,
    totpVerificationViewModelFactory: TOTPVerificationViewModel.Factory,
    completion: @escaping @MainActor (Result<(AuthTicket, Bool), Error>) -> Void
  ) {
    self.login = login
    self.mode = mode
    self.debugTokenPublisher = debugTokenPublisher
    self.totpVerificationViewModelFactory = totpVerificationViewModelFactory
    self.tokenVerificationViewModelFactory = tokenVerificationViewModelFactory
    self.completion = completion
    self.stateMachine = stateMachine
    Task {
      await self.perform(.start)
    }
  }

  public func update(
    for event: AccountVerificationStateMachine.Event,
    from oldState: AccountVerificationStateMachine.State,
    to newState: AccountVerificationStateMachine.State
  ) async {
    switch newState {
    case .initialize:
      self.viewState = .initializing
    case let .startVerification(method):
      switch method {
      case .emailToken:
        self.viewState = .emailToken
      case let .totp(pushType):
        self.viewState = .totp(hasDUOPush: pushType != nil)
      }
    case let .accountVerified(authTicket, isBackupCode):
      self.completion(.success((authTicket, isBackupCode)))
    case let .verificationFailed(error):
      self.completion(.failure(error.underlyingError))
    }
  }

}

extension AccountVerificationFlowModel {
  func makeTokenVerificationViewModel() -> TokenVerificationViewModel {
    tokenVerificationViewModelFactory.make(
      login: login, tokenPublisher: debugTokenPublisher,
      stateMachine: stateMachine.makeTokenVerificationStateMachine(), mode: mode
    ) { [weak self] result in
      guard let self = self else {
        return
      }
      Task {
        switch result {
        case let .success(authTicket):
          await self.perform(.verificationDidSuccess(authTicket, isBackupCode: false))
        case let .failure(error):
          await self.perform(.errorOcurred(StateMachineError(underlyingError: error)))
        }
      }
    }
  }

  func makeTOTPVerificationViewModel(pushType: VerificationMethod.PushType?)
    -> TOTPVerificationViewModel
  {
    totpVerificationViewModelFactory.make(
      login: login, stateMachine: stateMachine.makeTOTPVerificationStateMachine(),
      pushType: pushType
    ) { [weak self] result in
      guard let self = self else {
        return
      }
      Task {
        switch result {
        case let .success((authTicket, isBackupCode)):
          await self.perform(.verificationDidSuccess(authTicket, isBackupCode: isBackupCode))
        case let .failure(error):
          await self.perform(.errorOcurred(StateMachineError(underlyingError: error)))
        }
      }
    }
  }
}

extension AccountVerificationFlowModel {
  static func mock(verificationMethod: VerificationMethod) -> AccountVerificationFlowModel {
    AccountVerificationFlowModel(
      login: "", mode: .masterPassword, stateMachine: .mock,
      tokenVerificationViewModelFactory: .init({ _, _, _, _, _ in
        TokenVerificationViewModel.mock
      }),
      totpVerificationViewModelFactory: .init({ _, _, _, _ in
        TOTPVerificationViewModel.mock
      }), completion: { _ in })
  }
}
