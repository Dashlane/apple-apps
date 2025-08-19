import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import StateMachine

public struct DeviceTransferRecoveryFlowStateMachine: StateMachine {

  @Loggable
  public enum State: Hashable, Sendable {
    case initialize

    case intro

    case recoveryflow

    case accountResetFlow
  }

  @Loggable
  public enum Event: Sendable {
    case start

    case startRecovery

    case startAccountReset
  }

  public var state: State

  let appAPIClient: AppAPIClient
  let cryptoEngineProvider: CryptoEngineProvider
  let accountRecoveryInfo: AccountRecoveryInfo
  let deviceInfo: DeviceInfo
  let logger: Logger

  mutating public func transition(with event: Event) async throws {
    switch event {
    case .start:
      state = accountRecoveryInfo.accountType == .invisibleMasterPassword ? .intro : .recoveryflow
    case .startRecovery:
      state = .recoveryflow
    case .startAccountReset:
      state = .accountResetFlow
    }
    let state = state
    logger.info("Transition to state: \(state)")
  }
}

extension DeviceTransferRecoveryFlowStateMachine {
  public func makeAccountRecoveryKeyLoginFlowStateMachine()
    -> AccountRecoveryKeyLoginFlowStateMachine
  {
    AccountRecoveryKeyLoginFlowStateMachine(
      initialState: .loading, login: accountRecoveryInfo.login,
      loginType: .deviceToDevice(deviceInfo), accountType: accountRecoveryInfo.accountType,
      appAPIClient: appAPIClient, cryptoEngineProvider: cryptoEngineProvider, logger: logger)
  }
}

extension DeviceTransferRecoveryFlowStateMachine {
  public static var mock: DeviceTransferRecoveryFlowStateMachine {
    DeviceTransferRecoveryFlowStateMachine(
      state: .initialize,
      appAPIClient: .fake,
      cryptoEngineProvider: .mock(),
      accountRecoveryInfo: AccountRecoveryInfo(
        login: Login("_"), isEnabled: true, accountType: .invisibleMasterPassword),
      deviceInfo: .mock,
      logger: .mock)
  }
}
