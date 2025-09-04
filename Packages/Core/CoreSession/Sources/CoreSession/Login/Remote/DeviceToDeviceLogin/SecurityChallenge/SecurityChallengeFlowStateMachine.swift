import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import StateMachine

public struct SecurityChallengeFlowStateMachine: StateMachine {

  public enum State: Hashable, Sendable {
    case startSecurityChallengeTransfer(SecurityChallengeTransferStateMachine.State)

    case startPassphraseVerification(
      PassphraseVerificationStateMachine.State, SecurityChallengeKeys)

    case transferComplete(AccountTransferInfo)

    case challengeCancelled

    case challengeFailed
  }

  @Loggable
  public enum Event: Sendable {
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

  mutating public func transition(with event: Event) async throws {
    logger.info("Received event \(event)")
    switch (state, event) {
    case (.startSecurityChallengeTransfer, .startTransfer):
      state = .startSecurityChallengeTransfer(.initializing)
    case (.startSecurityChallengeTransfer, let .keysAndPassphraseReady(keys)):
      state = .startPassphraseVerification(.initializing, keys)
    case (.startPassphraseVerification, let .transferDataReceived(data)):
      state = .transferComplete(data)
    case (_, .cancelChallenge):
      state = .challengeCancelled
    case (_, .errorEncountered):
      state = .challengeFailed
    default:
      let errorMessage: LogMessage = "Unexpected \(event) event for the state \(state)"
      logger.fatal(errorMessage)
      throw InvalidTransitionError<Self>(event: event, state: state)
    }
    let state = state
    logger.info("Transition to state: \(state)")
  }
}

extension SecurityChallengeFlowStateMachine {
  public static var mock: SecurityChallengeFlowStateMachine {
    SecurityChallengeFlowStateMachine(
      state: .startSecurityChallengeTransfer(.initializing), appAPIClient: .fake, logger: .mock)
  }
}

extension SecurityChallengeFlowStateMachine {
  public func makePassphraseVerificationStateMachine(
    state: PassphraseVerificationStateMachine.State, transferId: String,
    secretBox: DeviceTransferSecretBox
  ) -> PassphraseVerificationStateMachine {
    PassphraseVerificationStateMachine(
      initialState: state, apiClient: appAPIClient, transferId: transferId, secretBox: secretBox,
      logger: logger)
  }

  public func makeSecurityChallengeTransferStateMachine(
    login: Login, cryptoProvider: DeviceTransferCryptoKeysProvider
  ) -> SecurityChallengeTransferStateMachine {
    SecurityChallengeTransferStateMachine(
      login: login, apiClient: appAPIClient, cryptoProvider: cryptoProvider, logger: logger)
  }
}
