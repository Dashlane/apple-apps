import Foundation

extension Definition {

  public enum `PhishingRisk`: String, Encodable, Sendable {
    case `high`
    case `moderate`
    case `none`
  }
}
