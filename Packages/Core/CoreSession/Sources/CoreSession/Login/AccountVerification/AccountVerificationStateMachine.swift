import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import StateMachine

public struct AccountVerificationStateMachine: StateMachine {

  @Loggable
  public enum State: Hashable, Sendable {
    case initialize
    case startVerification(VerificationMethod)
    case accountVerified(AuthTicket, isBackupCode: Bool)
    case verificationFailed(StateMachineError)
  }

  @Loggable
  public enum Event: Sendable {
    case start
    case errorOcurred(StateMachineError)
    case verificationDidSuccess(AuthTicket, isBackupCode: Bool)
  }

  public var state: State

  let login: Login
  let verificationMethod: VerificationMethod
  let appAPIClient: AppAPIClient
  let logger: Logger

  mutating public func transition(with event: Event) async throws {
    switch event {
    case .start:
      state = .startVerification(verificationMethod)
    case let .errorOcurred(error):
      state = .verificationFailed(error)
    case let .verificationDidSuccess(authTicket, isBackupCode):
      state = .accountVerified(authTicket, isBackupCode: isBackupCode)
    }
    let state = state
    logger.info("Transition to state: \(state)")
  }
}

extension AccountVerificationStateMachine {
  public static var mock: AccountVerificationStateMachine {
    AccountVerificationStateMachine(
      state: .initialize, login: Login("_"), verificationMethod: .emailToken, appAPIClient: .fake,
      logger: .mock)
  }
}

extension AccountVerificationStateMachine {
  public func makeTokenVerificationStateMachine() -> TokenVerificationStateMachine {
    TokenVerificationStateMachine(
      state: .waitingForTokenInput, login: login, appAPIClient: appAPIClient, logger: logger)
  }

  public func makeTOTPVerificationStateMachine() -> TOTPVerificationStateMachine {
    TOTPVerificationStateMachine(
      state: .initialize, login: login, appAPIClient: appAPIClient, logger: logger)
  }
}
