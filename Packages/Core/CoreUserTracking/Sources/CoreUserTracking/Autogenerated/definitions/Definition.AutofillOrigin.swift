import Foundation

extension Definition {

  public enum `AutofillOrigin`: String, Encodable, Sendable {
    case `automatic`
    case `dropdown`
    case `keyboard`
    case `notification`
  }
}
