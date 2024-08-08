import Foundation

extension Definition {

  public enum `ResponseStatus`: String, Encodable, Sendable {
    case `accepted`
    case `denied`
    case `error`
  }
}
