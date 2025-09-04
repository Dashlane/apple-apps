import Foundation

extension Definition {

  public enum `Plan`: String, Encodable, Sendable {
    case `business`
    case `businessPlus` = "business_plus"
    case `essentials`
    case `family`
    case `free`
    case `premium`
    case `standard`
    case `starter`
  }
}
