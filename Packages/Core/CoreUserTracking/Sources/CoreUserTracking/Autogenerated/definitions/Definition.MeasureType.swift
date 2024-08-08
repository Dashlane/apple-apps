import Foundation

extension Definition {

  public enum `MeasureType`: String, Encodable, Sendable {
    case `cpu`
    case `duration`
    case `memory`
  }
}
