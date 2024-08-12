import Foundation

extension Definition {

  public enum `DateOrigin`: String, Encodable, Sendable {
    case `local`
    case `remote`
  }
}
