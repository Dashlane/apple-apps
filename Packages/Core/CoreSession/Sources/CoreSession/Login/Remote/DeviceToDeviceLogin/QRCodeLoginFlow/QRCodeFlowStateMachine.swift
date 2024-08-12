import DashTypes
import DashlaneAPI
import Foundation
import StateMachine

@MainActor
public struct QRCodeFlowStateMachine: StateMachine {

  public enum State: Hashable {
    case startDeviceTransferQRCodeScan(QRCodeScanStateMachine.State)
    case verifyLogin(AccountTransferInfo)
    case completed(AccountTransferInfo)
    case cancelled
    case failed
  }

  public enum Event {
    case start
    case qrCodeScanDidFinish(AccountTransferInfo)
    case dataReceived(AccountTransferInfo)
    case abortEvent
  }

  let sessionCleaner: SessionCleanerProtocol
  let logger: Logger
  public var state: State

  public init(
    sessionCleaner: SessionCleanerProtocol,
    state: QRCodeFlowStateMachine.State,
    logger: Logger
  ) {
    self.state = state
    self.sessionCleaner = sessionCleaner
    self.logger = logger
  }

  mutating public func transition(with event: Event) async {
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
      state = .failed
      let errorMessage = "Unexpected \(event) event for the state \(state)"
      logger.error(errorMessage)
    }
    logger.logInfo("\(event) received, changes to state \(state)")
  }
}

extension QRCodeFlowStateMachine {
  public static var mock: QRCodeFlowStateMachine {
    QRCodeFlowStateMachine(
      sessionCleaner: .mock, state: .startDeviceTransferQRCodeScan(.waitingForQRCodeScan),
      logger: LoggerMock())
  }
}
