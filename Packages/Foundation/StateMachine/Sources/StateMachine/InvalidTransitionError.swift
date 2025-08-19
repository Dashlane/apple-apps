import Foundation

public struct InvalidTransitionError<S: StateMachine>: Error {
  public let event: S.Event
  public let state: S.State

  public init(event: S.Event, state: S.State) {
    self.event = event
    self.state = state
  }
}
