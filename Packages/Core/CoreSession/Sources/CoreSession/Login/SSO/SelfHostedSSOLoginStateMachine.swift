import DashTypes
import Foundation
import StateMachine

@MainActor
public struct SelfHostedSSOLoginStateMachine: StateMachine {

  public enum State: Hashable {
    case waitingForUserInput
    case receivedcallbackInfo(SSOCallbackInfos)
    case failed
    case cancelled
  }

  public enum Event {
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

  public mutating func transition(with event: Event) async {
    logger.logInfo("Received event \(event)")
    switch (state, event) {
    case (.waitingForUserInput, let .didReceiveCallback(url, error)):
      await handleCallback(url, error: error)
    case (_, .cancel):
      state = .cancelled
    default:
      let errorMessage = "Unexpected \(event) event for the state \(state)"
      logger.error(errorMessage)
    }
    logger.logInfo("Transition to state: \(state)")
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
