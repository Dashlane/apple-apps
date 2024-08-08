import DashTypes
import DashlaneAPI
import Foundation
import StateMachine

@MainActor
public struct SecurityChallengeFlowStateMachine: StateMachine {

  public enum State: Hashable {
    case startSecurityChallengeTransfer(SecurityChallengeTransferStateMachine.State)

    case startPassphraseVerification(
      PassphraseVerificationStateMachine.State, SecurityChallengeKeys)

    case transferComplete(AccountTransferInfo)

    case challengeCancelled

    case challengeFailed
  }

  public enum Event {
    case startTransfer

    case keysAndPassphraseReady(SecurityChallengeKeys)

    case transferDataReceived(AccountTransferInfo)

    case cancelChallenge

    case errorEncountered
  }

  public var state: State
  let logger: Logger
  let appAPIClient: AppAPIClient

  public init(
    state: SecurityChallengeFlowStateMachine.State,
    appAPIClient: AppAPIClient,
    logger: Logger
  ) {
    self.state = state
    self.logger = logger
    self.appAPIClient = appAPIClient
  }

  mutating public func transition(with event: Event) async {
    switch (state, event) {
    case (.startSecurityChallengeTransfer, .startTransfer):
      state = .startSecurityChallengeTransfer(.initializing)
    case (.startSecurityChallengeTransfer, let .keysAndPassphraseReady(keys)):
      state = .startPassphraseVerification(.initializing, keys)
    case (.startPassphraseVerification, let .transferDataReceived(data)):
      do {
        state = .transferComplete(data)
      } catch {
        state = .challengeFailed
      }
    case (_, .cancelChallenge):
      state = .challengeCancelled
    case (_, .errorEncountered):
      state = .challengeFailed
    default:
      let errorMessage = "Unexpected \(event) event for the state \(state)"
      logger.error(errorMessage)
    }
    logger.logInfo("\(event) received, changes to state \(state)")
  }
}

extension SecurityChallengeFlowStateMachine {
  public static var mock: SecurityChallengeFlowStateMachine {
    SecurityChallengeFlowStateMachine(
      state: .startSecurityChallengeTransfer(.initializing), appAPIClient: .fake,
      logger: LoggerMock())
  }
}
