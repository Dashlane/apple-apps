import CoreSession
import CoreTypes
import Foundation
import StateMachine

@MainActor
public class DeviceTransferRecoveryFlowModel: StateMachineBasedObservableObject,
  LoginKitServicesInjecting
{

  @Published
  var steps: [Step] = []

  let recoveryKeyLoginFlowModelFactory: AccountRecoveryKeyLoginFlowModel.Factory
  let completion: @MainActor (AccountRecoveryKeyLoginFlowModel.Completion) -> Void

  enum Step: Hashable {
    case intro
    case accountReset
    case recoveryFlow
  }

  @Published public var stateMachine: DeviceTransferRecoveryFlowStateMachine
  @Published public var isPerformingEvent: Bool = false
  let login: Login

  public init(
    login: Login,
    stateMachine: DeviceTransferRecoveryFlowStateMachine,
    recoveryKeyLoginFlowModelFactory: AccountRecoveryKeyLoginFlowModel.Factory,
    completion: @escaping @MainActor (AccountRecoveryKeyLoginFlowModel.Completion) -> Void
  ) {
    self.stateMachine = stateMachine
    self.recoveryKeyLoginFlowModelFactory = recoveryKeyLoginFlowModelFactory
    self.completion = completion
    self.login = login
    Task {
      await self.perform(.start)
    }
  }

  public func update(
    for event: DeviceTransferRecoveryFlowStateMachine.Event,
    from oldState: DeviceTransferRecoveryFlowStateMachine.State,
    to newState: DeviceTransferRecoveryFlowStateMachine.State
  ) async {
    switch newState {
    case .initialize: break
    case .intro:
      self.steps.append(.intro)
    case .recoveryflow:
      self.steps.append(.recoveryFlow)
    case .accountResetFlow:
      self.steps.append(.accountReset)
    }
  }

  func startRecoveryFlow() async {
    await self.perform(.startRecovery)
  }

  func resetAccount() async {
    await self.perform(.startAccountReset)
  }

  func makeAccountRecoveryFlowModel() -> AccountRecoveryKeyLoginFlowModel {
    return recoveryKeyLoginFlowModelFactory.make(
      login: login, stateMachine: stateMachine.makeAccountRecoveryKeyLoginFlowStateMachine(),
      completion: completion
    )
  }
}
