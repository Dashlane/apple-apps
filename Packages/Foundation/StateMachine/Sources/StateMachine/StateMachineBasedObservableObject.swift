import Foundation

#if canImport(Combine)
  #if canImport(SwiftUI)

    import SwiftUI
    import Combine

    @MainActor
    public protocol StateMachineBasedObservableObject: ObservableObject {
      associatedtype Machine: StateMachine

      var stateMachine: Machine { get set }

      var isPerformingEvent: Bool { get set }

      func willPerform(_ event: Machine.Event) async

      func update(
        for event: Machine.Event, from oldState: Machine.State, to newState: Machine.State) async
    }

    @MainActor
    extension StateMachineBasedObservableObject
    where Self.ObjectWillChangePublisher == ObservableObjectPublisher {
      public var state: Machine.State {
        stateMachine.state
      }

      public func willPerform(_ event: Machine.Event) async {

      }

      public func perform(_ event: Machine.Event) async {
        let oldState = stateMachine.state
        var stateMachine = stateMachine
        do {
          guard !isPerformingEvent else {
            return
          }

          isPerformingEvent = true

          await willPerform(event)

          try await Task.detached {
            try await stateMachine.transition(with: event)
          }.value

          self.stateMachine = stateMachine
          isPerformingEvent = false
          await update(for: event, from: oldState, to: stateMachine.state)
        } catch is InvalidTransitionError<Machine> {
          isPerformingEvent = false
        } catch {
          self.stateMachine = stateMachine
          isPerformingEvent = false
          await update(for: event, from: oldState, to: stateMachine.state)
        }
      }
    }

  #endif
#endif
