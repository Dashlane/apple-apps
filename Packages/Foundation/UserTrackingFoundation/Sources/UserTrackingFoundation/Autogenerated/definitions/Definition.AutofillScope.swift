import Foundation

extension Definition {

  public enum `AutofillScope`: String, Encodable, Sendable {
    case `field`
    case `global`
    case `page`
    case `site`
  }
}
