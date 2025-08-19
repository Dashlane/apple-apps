import Foundation

extension Definition {

  public enum `AutofillOrigin`: String, Encodable, Sendable {
    case `automatic`
    case `contextMenu` = "context_menu"
    case `dropdown`
    case `keyboard`
    case `notification`
  }
}
