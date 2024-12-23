import Foundation

extension Definition {

  public enum `CorrectionType`: String, Encodable, Sendable {
    case `changeClassification` = "change_classification"
    case `edit`
    case `erase`
    case `overwrite`
  }
}
