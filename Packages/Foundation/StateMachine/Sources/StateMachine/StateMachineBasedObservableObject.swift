import Foundation

#if canImport(Combine)
  #if canImport(SwiftUI)

    import SwiftUI
    import Combine

    public protocol StateMachineBasedObservableObject: ObservableObject {
      associatedtype Machine: StateMachine

      var stateMachine: Machine { get set }

      @MainActor
      func update(
        for event: Machine.Event, from oldState: Machine.State, to newState: Machine.State) async
    }

    @MainActor
    extension StateMachineBasedObservableObject
    where Self.ObjectWillChangePublisher == ObservableObjectPublisher {
      public var state: Machine.State {
        stateMachine.state
      }

      public func perform(_ event: Machine.Event) async {
        let oldState = stateMachine.state
        self.objectWillChange.send()
        await stateMachine.transition(with: event)
        await update(for: event, from: oldState, to: stateMachine.state)
      }
    }

  #endif
#endif
