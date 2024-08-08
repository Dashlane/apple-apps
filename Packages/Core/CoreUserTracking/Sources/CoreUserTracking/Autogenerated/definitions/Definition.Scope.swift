import Foundation

extension Definition {

  public enum `Scope`: String, Encodable, Sendable {
    case `global`
    case `personal`
    case `team`
  }
}
