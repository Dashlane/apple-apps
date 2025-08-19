import Foundation

extension UserEvent {

  public struct `TransferNewDevice`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `action`: Definition.ActionDuringTransfer, `biometricsEnabled`: Bool,
      `loggedInDeviceSelected`: Definition.DeviceSelected,
      `transferMethod`: Definition.TransferMethod
    ) {
      self.action = action
      self.biometricsEnabled = biometricsEnabled
      self.loggedInDeviceSelected = loggedInDeviceSelected
      self.transferMethod = transferMethod
    }
    public let action: Definition.ActionDuringTransfer
    public let biometricsEnabled: Bool
    public let loggedInDeviceSelected: Definition.DeviceSelected
    public let name = "transfer_new_device"
    public let transferMethod: Definition.TransferMethod
  }
}
