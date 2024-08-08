import Foundation

extension Definition {

  public enum `Extent`: String, Encodable, Sendable {
    case `full`
    case `initial`
    case `light`
  }
}
