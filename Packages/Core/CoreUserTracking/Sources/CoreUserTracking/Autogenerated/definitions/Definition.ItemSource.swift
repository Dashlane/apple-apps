import Foundation

extension Definition {

  public enum `ItemSource`: String, Encodable, Sendable {
    case `manual`
    case `shared`
  }
}
