import Foundation

extension Definition {

  public enum `Unit`: String, Encodable, Sendable {
    case `gb`
    case `mb`
    case `milliseconds`
    case `percent`
    case `seconds`
  }
}
