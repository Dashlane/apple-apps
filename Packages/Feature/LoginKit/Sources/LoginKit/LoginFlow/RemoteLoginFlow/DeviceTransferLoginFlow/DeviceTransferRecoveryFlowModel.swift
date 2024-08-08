import CoreSession
import Foundation

@MainActor
public class DeviceTransferRecoveryFlowModel: ObservableObject, LoginKitServicesInjecting {

  @Published
  var steps: [Step]

  let accountRecoveryInfo: AccountRecoveryInfo
  let deviceInfo: DeviceInfo
  let recoveryKeyLoginFlowModelFactory: AccountRecoveryKeyLoginFlowModel.Factory
  let completion: @MainActor (AccountRecoveryKeyLoginFlowModel.Completion) -> Void

  enum Step: Hashable {
    case intro
    case accountReset
    case recoveryFlow
  }

  public init(
    accountRecoveryInfo: AccountRecoveryInfo,
    deviceInfo: DeviceInfo,
    recoveryKeyLoginFlowModelFactory: AccountRecoveryKeyLoginFlowModel.Factory,
    completion: @escaping @MainActor (AccountRecoveryKeyLoginFlowModel.Completion) -> Void
  ) {
    self.steps =
      accountRecoveryInfo.accountType == .invisibleMasterPassword ? [.intro] : [.recoveryFlow]
    self.accountRecoveryInfo = accountRecoveryInfo
    self.deviceInfo = deviceInfo
    self.recoveryKeyLoginFlowModelFactory = recoveryKeyLoginFlowModelFactory
    self.completion = completion
  }

  func startRecoveryFlow() {
    self.steps.append(.recoveryFlow)
  }

  func resetAccount() {
    self.steps.append(.accountReset)
  }

  func makeAccountRecoveryFlowModel() -> AccountRecoveryKeyLoginFlowModel {
    return recoveryKeyLoginFlowModelFactory.make(
      login: accountRecoveryInfo.login,
      accountType: accountRecoveryInfo.accountType,
      loginType: .deviceToDevice(deviceInfo),
      completion: completion
    )
  }
}
