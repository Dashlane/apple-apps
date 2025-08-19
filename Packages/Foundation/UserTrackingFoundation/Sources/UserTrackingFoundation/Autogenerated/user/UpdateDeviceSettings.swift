import Foundation

extension UserEvent {

  public struct `UpdateDeviceSettings`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(`deviceAppearance`: Definition.DeviceAppearance? = nil) {
      self.deviceAppearance = deviceAppearance
    }
    public let deviceAppearance: Definition.DeviceAppearance?
    public let name = "update_device_settings"
  }
}
