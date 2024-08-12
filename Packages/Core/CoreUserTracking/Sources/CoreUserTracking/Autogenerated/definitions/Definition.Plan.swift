import Foundation

extension Definition {

  public enum `Plan`: String, Encodable, Sendable {
    case `essentials`
    case `family`
    case `free`
    case `premium`
  }
}
