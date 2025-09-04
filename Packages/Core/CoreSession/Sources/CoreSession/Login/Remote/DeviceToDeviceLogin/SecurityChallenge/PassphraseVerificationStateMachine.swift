import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import StateMachine

public struct PassphraseVerificationStateMachine: StateMachine {

  @Loggable
  public enum State: Hashable, Sendable {
    case initializing
    case transferCompleted(AccountTransferInfo)
    case transferError(TransferError)
    case cancelled
  }

  @Loggable
  public enum Event: Sendable {
    case requestTransferData
    case cancel
  }

  let apiClient: AppAPIClient
  let transferId: String
  let secretBox: DeviceTransferSecretBox
  let logger: Logger

  public var state: State

  public init(
    initialState: PassphraseVerificationStateMachine.State,
    apiClient: AppAPIClient,
    transferId: String,
    secretBox: DeviceTransferSecretBox,
    logger: Logger
  ) {
    self.state = initialState
    self.apiClient = apiClient
    self.transferId = transferId
    self.secretBox = secretBox
    self.logger = logger
  }

  mutating public func transition(with event: Event) async throws {
    logger.info("Received event \(event)")
    switch (state, event) {
    case (.initializing, .requestTransferData):
      await requestTransferData()
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

  mutating private func requestTransferData() async {
    do {
      let transferInfo = try await apiClient.secretTransfer.startTransfer(
        transferType: .universal, transferId: transferId)
      let decodedData: DeviceToDeviceTransferData = try secretBox.open(
        DeviceToDeviceTransferData.self, from: transferInfo.encryptedData, nonce: transferInfo.nonce
      )
      let validData = try await AccountTransferInfo(receivedData: decodedData, apiClient: apiClient)
      state = .transferCompleted(validData)
    } catch let error as URLError where error.code == .timedOut {
      state = .transferError(.timeout)
      logger.error("Passphrase verification failed", error: error)
    } catch {
      state = .transferError(.unknown)
      logger.error("Passphrase verification failed", error: error)
    }

  }
}

extension PassphraseVerificationStateMachine {
  public static var mock: PassphraseVerificationStateMachine {
    PassphraseVerificationStateMachine(
      initialState: .initializing, apiClient: .fake, transferId: "transferId",
      secretBox: DeviceTransferSecretBoxMock.mock(), logger: .mock)
  }
}
