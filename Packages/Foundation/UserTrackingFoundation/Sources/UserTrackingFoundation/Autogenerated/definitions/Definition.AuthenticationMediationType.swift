import Foundation

extension Definition {

  public enum `AuthenticationMediationType`: String, Encodable, Sendable {
    case `conditional`
    case `optional`
    case `required`
    case `silent`
  }
}
