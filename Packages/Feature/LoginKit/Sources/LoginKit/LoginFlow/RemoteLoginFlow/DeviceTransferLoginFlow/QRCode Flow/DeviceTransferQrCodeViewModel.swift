import CoreCrypto
import CoreLocalization
import CoreSession
import CoreUserTracking
import DashTypes
import DashlaneAPI
import Foundation
import StateMachine

@MainActor
public class DeviceTransferQrCodeViewModel: ObservableObject, LoginKitServicesInjecting {

  public enum CompletionType {
    case qrFinished
    case recovery(AccountRecoveryInfo)
    case securityChallenge
    case cancel
  }

  @Published
  var inProgress = true

  @Published
  var qrCodeUrl: String?

  @Published
  var progressState: ProgressionState = .inProgress("")

  @Published
  var showError = false

  @Published
  var accountRecoveryInfo: AccountRecoveryInfo?

  private let completion: (DeviceTransferCompletion) -> Void

  public var stateMachine: QRCodeScanStateMachine

  private let activityReporter: ActivityReporterProtocol

  public init(
    login: Login?,
    state: QRCodeScanStateMachine.State,
    activityReporter: ActivityReporterProtocol,
    deviceTransferQRCodeStateMachineFactory: QRCodeScanStateMachine.Factory,
    completion: @escaping (DeviceTransferCompletion) -> Void
  ) {
    self.completion = completion
    self.activityReporter = activityReporter
    self.stateMachine = deviceTransferQRCodeStateMachineFactory.make(
      login: login, state: state, qrDeviceTransferCrypto: ECDH())
    Task {
      await start()
    }
  }

  func start() async {
    await perform(.requestTransferInfo)
  }

  func retry() {
    showError = false
    Task {
      await start()
    }
  }

  func cancel() {
    completion(.dismiss)
  }

  func showAccountRecovery(with info: AccountRecoveryInfo) {
    activityReporter.report(
      UserEvent.TransferNewDevice(
        action: .selectTransferMethod, biometricsEnabled: false,
        loggedInDeviceSelected: .noDeviceAvailable, transferMethod: .accountRecoveryKey))
    completion(.recovery(info))
  }

  func showSecurityChallenge() {
    activityReporter.report(
      UserEvent.TransferNewDevice(
        action: .selectTransferMethod, biometricsEnabled: false, loggedInDeviceSelected: .computer,
        transferMethod: .securityChallenge))
    completion(.changeFlow)
  }
}

@MainActor
extension DeviceTransferQrCodeViewModel: StateMachineBasedObservableObject {

  public func update(
    for event: Machine.Event, from oldState: Machine.State, to newState: Machine.State
  ) async {
    switch newState {
    case .waitingForQRCodeScan:
      inProgress = true
    case let .readyForTransfer(info):
      qrCodeUrl = info.qrCodeURL
      accountRecoveryInfo = info.accountRecoveryInfo
      inProgress = false
      await self.perform(.beginTransfer(withID: info.transferId))
    case let .transferring(info):
      progressState = .inProgress(L10n.Core.deviceToDeviceLoadingProgress)
      inProgress = true
      await perform(.sendTransferData(response: info))
    case let .transferCompleted(data):
      self.completion(.completed(data))
    case .transferError:
      showError = true
    }
  }
}
