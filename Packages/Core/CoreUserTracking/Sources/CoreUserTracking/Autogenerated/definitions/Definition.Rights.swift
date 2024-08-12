import Foundation

extension Definition {

  public enum `Rights`: String, Encodable, Sendable {
    case `limited`
    case `revoked`
    case `unlimited`
  }
}
