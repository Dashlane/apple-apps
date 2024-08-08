@MainActor
public protocol StateMachine<State, Event>: Sendable {
  associatedtype State: Hashable
  associatedtype Event

  var state: State { get }

  mutating func transition(with event: Event) async
}
