import Foundation

extension Definition {

  public enum `SaveType`: String, Encodable, Sendable {
    case `replace`
    case `save`
    case `saveAsNew` = "save_as_new"
  }
}
