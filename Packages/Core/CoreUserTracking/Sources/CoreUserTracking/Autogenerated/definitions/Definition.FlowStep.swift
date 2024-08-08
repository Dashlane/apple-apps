import Foundation

extension Definition {

  public enum `FlowStep`: String, Encodable, Sendable {
    case `cancel`
    case `complete`
    case `error`
    case `start`
  }
}
