import Foundation

extension Definition {

  public enum `RequestStatus`: String, Encodable, Sendable {
    case `error`
    case `shared`
  }
}
