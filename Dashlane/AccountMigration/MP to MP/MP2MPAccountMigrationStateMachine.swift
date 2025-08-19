import CoreKeychain
import CorePasswords
import CorePremium
import CoreSession
import CoreTypes
import Foundation
import Logger
import LoginKit
import StateMachine
import UserTrackingFoundation

struct MP2MPAccountMigrationStateMachine: StateMachine {

  var state: State = .confirmation

  enum State: Sendable, Hashable {
    case confirmation
    case waitingForMasterPassword
    case migration(AccountMigrationConfiguration)
    case completed(Session)
    case failed(StateMachineError)
    case cancelled
  }

  enum Event {
    case enterMasterPassword
    case masterPasswordEntered(String)
    case complete(Session)
    case fail(Error)
    case back
  }

  private let session: Session

  init(session: Session) {
    self.session = session
  }

  mutating func transition(with event: Event) async throws {
    switch event {
    case .enterMasterPassword:
      switch state {
      case .confirmation:
        self.state = .waitingForMasterPassword

      case .waitingForMasterPassword, .migration, .completed, .failed, .cancelled:
        throw InvalidTransitionError<Self>(event: event, state: state)
      }

    case .masterPasswordEntered(let masterPassword):
      switch state {
      case .waitingForMasterPassword:
        self.state = .migration(
          .masterPasswordToMasterPassword(session: session, masterPassword: masterPassword))

      case .confirmation, .migration, .completed, .failed, .cancelled:
        throw InvalidTransitionError<Self>(event: event, state: state)
      }

    case .complete(let session):
      switch state {
      case .migration:
        self.state = .completed(session)

      case .confirmation, .waitingForMasterPassword, .cancelled, .completed, .failed:
        throw InvalidTransitionError<Self>(event: event, state: state)
      }

    case .fail(let error):
      switch state {
      case .confirmation, .waitingForMasterPassword, .migration:
        self.state = .failed(StateMachineError(underlyingError: error))

      case .completed, .cancelled, .failed:
        throw InvalidTransitionError<Self>(event: event, state: state)
      }

    case .back:
      switch state {
      case .confirmation:
        self.state = .cancelled
      case .waitingForMasterPassword:
        self.state = .confirmation
      case .migration, .completed, .failed, .cancelled:
        throw InvalidTransitionError<Self>(event: event, state: state)
      }
    }
  }
}
