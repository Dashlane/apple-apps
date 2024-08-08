import Foundation

extension Definition {

  public enum `DeviceSelected`: String, Encodable, Sendable {
    case `any`
    case `computer`
    case `mobile`
    case `noDeviceAvailable` = "no_device_available"
  }
}
