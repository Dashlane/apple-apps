import Foundation

extension Definition {

  public enum `CeremonyStatus`: String, Encodable, Sendable {
    case `cancelled`
    case `failure`
    case `success`
  }
}
