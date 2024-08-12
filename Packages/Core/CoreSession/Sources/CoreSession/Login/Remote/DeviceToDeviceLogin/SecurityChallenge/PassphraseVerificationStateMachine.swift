import DashTypes
import DashlaneAPI
import Foundation
import StateMachine

@MainActor
public struct PassphraseVerificationStateMachine: StateMachine {

  public enum State: Hashable, Sendable {
    case initializing
    case transferCompleted(AccountTransferInfo)
    case transferError(TransferError)
    case cancelled
  }

  public enum Event {
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

  mutating public func transition(with event: Event) async {
    logger.logInfo("Received event \(event)")
    switch (state, event) {
    case (.initializing, .requestTransferData):
      await requestTransferData()
    case (_, .cancel):
      state = .cancelled
    default:
      let errorMessage = "Unexpected \(event) event for the state \(state)"
      logger.error(errorMessage)
    }
  }

  mutating private func requestTransferData() async {
    do {
      let transferInfo = try await apiClient.secretTransfer.startTransfer(
        transferType: .universal, transferId: transferId)
      let decodedData: DeviceToDeviceTransferData = try secretBox.open(
        DeviceToDeviceTransferData.self, from: transferInfo.encryptedData, nonce: transferInfo.nonce
      )
      logger.logInfo("Transition to state: \(state)")
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
      secretBox: DeviceTransferSecretBoxMock.mock(), logger: LoggerMock())
  }
}
