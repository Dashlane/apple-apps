import Foundation

extension Definition {

  public enum `ItemTypeWithLink`: String, Encodable, Sendable {
    case `credential`
    case `passkey`
  }
}
