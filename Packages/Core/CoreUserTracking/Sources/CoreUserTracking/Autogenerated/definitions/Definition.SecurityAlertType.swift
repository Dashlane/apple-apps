import Foundation

extension Definition {

  public enum `SecurityAlertType`: String, Encodable, Sendable {
    case `darkWeb` = "dark_web"
    case `publicBreach` = "public_breach"
  }
}
