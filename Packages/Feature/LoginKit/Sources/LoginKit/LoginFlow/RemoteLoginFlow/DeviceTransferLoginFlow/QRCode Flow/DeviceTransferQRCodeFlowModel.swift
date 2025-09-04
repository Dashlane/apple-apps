import Combine
import CoreCrypto
import CoreLocalization
import CoreSession
import CoreTypes
import DashlaneAPI
import Foundation
import StateMachine
import UserTrackingFoundation

@MainActor
public class DeviceTransferQRCodeFlowModel: LoginKitServicesInjecting {
  public enum Completion {
    case logout
    case dismiss
    case completed(RemoteLoginSession, LoginFlowLogInfo)
  }

  enum Step {
    case intro(QRCodeScanStateMachine.State)
    case verifyLogin(AccountTransferInfo)
  }

  @Published
  var steps: [Step] = []

  @Published
  var isInProgress = false

  let login: Login?
  let completion: @MainActor (DeviceTransferCompletion) -> Void
  let qrCodeLoginViewModelFactory: DeviceTransferQrCodeViewModel.Factory
  private let accountRecoveryKeyLoginFlowModelFactory: AccountRecoveryKeyLoginFlowModel.Factory

  @Published public var stateMachine: QRCodeFlowStateMachine
  @Published public var isPerformingEvent: Bool = false

  public init(
    login: Login?,
    stateMachine: QRCodeFlowStateMachine,
    qrCodeLoginViewModelFactory: DeviceTransferQrCodeViewModel.Factory,
    accountRecoveryKeyLoginFlowModelFactory: AccountRecoveryKeyLoginFlowModel.Factory,
    completion: @escaping @MainActor (DeviceTransferCompletion) -> Void
  ) {
    self.completion = completion
    self.qrCodeLoginViewModelFactory = qrCodeLoginViewModelFactory
    self.accountRecoveryKeyLoginFlowModelFactory = accountRecoveryKeyLoginFlowModelFactory
    self.stateMachine = stateMachine
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
    return qrCodeLoginViewModelFactory.make(
      login: login,
      stateMachine: stateMachine.makeQRCodeScanStateMachine(
        login: login, state: state, qrDeviceTransferCrypto: ECDH())
    ) { [weak self] result in
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
    }
  }
}

extension DeviceTransferQRCodeFlowModel {
  static var mock: DeviceTransferQRCodeFlowModel {
    DeviceTransferQRCodeFlowModel(
      login: Login("_"),
      stateMachine: .mock,
      qrCodeLoginViewModelFactory: .init { login, _, completion in
        DeviceTransferQrCodeViewModel(
          login: login,
          stateMachine: .mock,
          activityReporter: ActivityReporterMock(),
          completion: completion
        )
      },
      accountRecoveryKeyLoginFlowModelFactory: .init({ _, _, _ in
        .mock
      }),
      completion: { _ in }
    )
  }
}
