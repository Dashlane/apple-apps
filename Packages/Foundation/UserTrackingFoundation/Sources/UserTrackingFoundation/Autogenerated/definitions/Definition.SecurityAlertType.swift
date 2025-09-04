import Foundation

extension Definition {

  public enum `SecurityAlertType`: String, Encodable, Sendable {
    case `darkWeb` = "dark_web"
    case `nudgeDashlaneExtension` = "nudge_dashlane_extension"
    case `nudgeInContext` = "nudge_in_context"
    case `publicBreach` = "public_breach"
  }
}
