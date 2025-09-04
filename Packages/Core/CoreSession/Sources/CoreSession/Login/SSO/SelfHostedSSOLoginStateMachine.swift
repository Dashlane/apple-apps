import CoreTypes
import Foundation
import LogFoundation
import StateMachine

public struct SelfHostedSSOLoginStateMachine: StateMachine {

  @Loggable
  public enum State: Hashable, Sendable {
    case waitingForUserInput
    case receivedcallbackInfo(SSOCallbackInfos)
    case failed
    case cancelled
  }

  @Loggable
  public enum Event: Sendable {
    case didReceiveCallback(URL?, Error?)
    case cancel
  }

  public var state: State = .waitingForUserInput

  private let login: Login
  private let logger: Logger

  public init(
    login: Login,
    logger: Logger
  ) {
    self.login = login
    self.logger = logger
  }

  public mutating func transition(with event: Event) async throws {
    logger.info("Received event \(event)")
    switch (state, event) {
    case (.waitingForUserInput, let .didReceiveCallback(url, error)):
      await handleCallback(url, error: error)
    case (_, .cancel):
      state = .cancelled
    default:
      let errorMessage: LogMessage = "Unexpected \(event) event for the state \(state)"
      logger.fatal(errorMessage)
      throw InvalidTransitionError<Self>(event: event, state: state)
    }
    let state = state
    logger.info("Transition to state: \(state)")
  }

  private mutating func handleCallback(_ callbackURL: URL?, error: Error?) async {
    guard let callbackURL else {
      state = .cancelled
      return
    }

    guard let callbackInfos = SSOCallbackInfos(url: callbackURL) else {
      state = .failed
      return
    }
    state = .receivedcallbackInfo(callbackInfos)
  }
}
