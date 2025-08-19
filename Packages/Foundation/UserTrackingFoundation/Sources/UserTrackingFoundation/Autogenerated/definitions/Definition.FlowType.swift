import Foundation

extension Definition {

  public enum `FlowType`: String, Encodable, Sendable {
    case `activation`
    case `deactivation`
  }
}
