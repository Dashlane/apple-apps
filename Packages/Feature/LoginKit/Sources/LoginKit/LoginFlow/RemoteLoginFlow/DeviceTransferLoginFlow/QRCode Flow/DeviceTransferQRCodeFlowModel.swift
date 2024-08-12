import Combine
import CoreLocalization
import CoreSession
import CoreUserTracking
import DashTypes
import DashlaneAPI
import Foundation
import StateMachine

@MainActor
public class DeviceTransferQRCodeFlowModel: LoginKitServicesInjecting {

  public enum Completion {
    case logout
    case dismiss
    case completed(RemoteLoginSession, LoginFlowLogInfo)
  }

  @Published
  var steps: [Step] = []

  let completion: @MainActor (DeviceTransferCompletion) -> Void
  let qrCodeLoginViewModelFactory: DeviceTransferQrCodeViewModel.Factory
  private let accountRecoveryKeyLoginFlowModelFactory: AccountRecoveryKeyLoginFlowModel.Factory
  public var stateMachine: QRCodeFlowStateMachine
  let login: Login?

  @Published
  var isInProgress = false

  enum Step {
    case intro(QRCodeScanStateMachine.State)
    case verifyLogin(AccountTransferInfo)
  }

  @Published
  var showError = false

  var shouldEnableBiometry: Bool = false

  public init(
    login: Login?,
    state: QRCodeFlowStateMachine.State,
    qrCodeLoginViewModelFactory: DeviceTransferQrCodeViewModel.Factory,
    accountRecoveryKeyLoginFlowModelFactory: AccountRecoveryKeyLoginFlowModel.Factory,
    deviceTransferQRCodeFlowStateMachineFactory: QRCodeFlowStateMachine.Factory,
    completion: @escaping @MainActor (DeviceTransferCompletion) -> Void
  ) {
    self.completion = completion
    self.qrCodeLoginViewModelFactory = qrCodeLoginViewModelFactory
    self.accountRecoveryKeyLoginFlowModelFactory = accountRecoveryKeyLoginFlowModelFactory
    self.stateMachine = deviceTransferQRCodeFlowStateMachineFactory.make(state: state)
    self.login = login
    Task {
      await self.perform(.start)
    }
  }
}

extension DeviceTransferQRCodeFlowModel {
  func makeDeviceToDeviceLoginQrCodeViewModel(state: QRCodeScanStateMachine.State)
    -> DeviceTransferQrCodeViewModel
  {
    return qrCodeLoginViewModelFactory.make(login: login, state: state) { [weak self] result in
      guard let self = self else {
        return
      }
      Task {
        switch result {
        case let .completed(data):
          await self.perform(.qrCodeScanDidFinish(data))
        default:
          self.completion(result)
        }
      }
    }
  }
}

@MainActor
extension DeviceTransferQRCodeFlowModel: StateMachineBasedObservableObject {
  public func update(
    for event: QRCodeFlowStateMachine.Event, from oldState: QRCodeFlowStateMachine.State,
    to newState: QRCodeFlowStateMachine.State
  ) {
    switch newState {
    case let .startDeviceTransferQRCodeScan(state):
      self.steps.append(.intro(state))
    case let .verifyLogin(data):
      self.steps.append(.verifyLogin(data))
    case .cancelled:
      self.completion(.dismiss)
    case let .completed(data):
      self.completion(.completed(data))
    case .failed:
      self.showError = true
      isInProgress = false
    }
  }
}

extension DeviceTransferQRCodeFlowModel {
  static var mock: DeviceTransferQRCodeFlowModel {
    DeviceTransferQRCodeFlowModel(
      login: Login("_"),
      state: .startDeviceTransferQRCodeScan(.waitingForQRCodeScan),
      qrCodeLoginViewModelFactory: .init { login, state, completion in
        DeviceTransferQrCodeViewModel(
          login: login,
          state: state,
          activityReporter: ActivityReporterMock(),
          deviceTransferQRCodeStateMachineFactory: .init({ login, state, ecdh in
            QRCodeScanStateMachine(
              login: login, state: state, appAPIClient: .fake,
              sessionCryptoEngineProvider: FakeCryptoEngineProvider(), qrDeviceTransferCrypto: ecdh,
              logger: LoggerMock())
          }),
          completion: completion
        )
      },
      accountRecoveryKeyLoginFlowModelFactory: .init({ _, _, _, _ in
        .mock
      }),
      deviceTransferQRCodeFlowStateMachineFactory: .init({ state in
        QRCodeFlowStateMachine(sessionCleaner: .mock, state: state, logger: LoggerMock())
      }),
      completion: { _ in }
    )
  }
}
