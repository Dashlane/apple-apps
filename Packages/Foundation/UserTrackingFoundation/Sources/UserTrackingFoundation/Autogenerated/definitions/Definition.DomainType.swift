import Foundation

extension Definition {

  public enum `DomainType`: String, Encodable, Sendable {
    case `app`
    case `web`
  }
}
