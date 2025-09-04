import Foundation

extension Definition {

  public enum `Mode`: String, Encodable, Sendable {
    case `biometric`
    case `deviceTransfer` = "device_transfer"
    case `masterPassword` = "master_password"
    case `notSelected` = "not_selected"
    case `passkey`
    case `pin`
    case `sso`
  }
}
