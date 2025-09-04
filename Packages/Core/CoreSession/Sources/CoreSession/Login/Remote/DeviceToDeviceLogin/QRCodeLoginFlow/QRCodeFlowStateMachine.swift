import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import StateMachine

public struct QRCodeFlowStateMachine: StateMachine {

  @Loggable
  public enum State: Hashable, Sendable {
    case startDeviceTransferQRCodeScan(QRCodeScanStateMachine.State)
    case verifyLogin(AccountTransferInfo)
    case completed(AccountTransferInfo)
    case cancelled
  }

  @Loggable
  public enum Event: Sendable {
    case start
    case qrCodeScanDidFinish(AccountTransferInfo)
    case dataReceived(AccountTransferInfo)
    case abortEvent
  }

  let appAPIClient: AppAPIClient
  let sessionCryptoEngineProvider: CryptoEngineProvider
  let sessionCleaner: SessionCleanerProtocol
  let logger: Logger
  public var state: State

  public init(
    appAPIClient: AppAPIClient,
    sessionCryptoEngineProvider: CryptoEngineProvider,
    sessionCleaner: SessionCleanerProtocol,
    state: QRCodeFlowStateMachine.State,
    logger: Logger
  ) {
    self.state = state
    self.appAPIClient = appAPIClient
    self.sessionCleaner = sessionCleaner
    self.logger = logger
    self.sessionCryptoEngineProvider = sessionCryptoEngineProvider
  }

  mutating public func transition(with event: Event) async throws {
    logger.info("Received event \(event)")
    switch (state, event) {
    case (.startDeviceTransferQRCodeScan, .start):
      state = .startDeviceTransferQRCodeScan(.waitingForQRCodeScan)
    case (.startDeviceTransferQRCodeScan, let .qrCodeScanDidFinish(data)):
      state = .verifyLogin(data)
    case (.verifyLogin, let .dataReceived(data)):
      logger.info("Removing local data")
      sessionCleaner.removeLocalData(for: data.login)
      state = .completed(data)
    case (_, .abortEvent):
      state = .cancelled
    default:
      let errorMessage: LogMessage = "Unexpected \(event) event for the state \(state)"
      logger.fatal(errorMessage)
      throw InvalidTransitionError<Self>(event: event, state: state)
    }
    let state = state
    logger.info("Transition to state: \(state)")
  }
}

extension QRCodeFlowStateMachine {
  public static var mock: QRCodeFlowStateMachine {
    QRCodeFlowStateMachine(
      appAPIClient: .mock({}), sessionCryptoEngineProvider: .mock(), sessionCleaner: .mock,
      state: .startDeviceTransferQRCodeScan(.waitingForQRCodeScan), logger: .mock)
  }
}

extension QRCodeFlowStateMachine {
  public func makeQRCodeScanStateMachine(
    login: Login?, state: QRCodeScanStateMachine.State, qrDeviceTransferCrypto: ECDHProtocol
  ) -> QRCodeScanStateMachine {
    QRCodeScanStateMachine(
      login: login, state: state, appAPIClient: appAPIClient,
      sessionCryptoEngineProvider: sessionCryptoEngineProvider,
      qrDeviceTransferCrypto: qrDeviceTransferCrypto, logger: logger)
  }
}
