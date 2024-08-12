import Foundation

extension Definition {

  public enum `UpdateStatus`: String, Encodable, Sendable {
    case `error`
    case `updated`
  }
}
