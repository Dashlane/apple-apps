import Foundation

extension Definition {

  public enum `DeviceAppearance`: String, Encodable, Sendable {
    case `dark`
    case `debug`
    case `light`
    case `matchSystem` = "match_system"
  }
}
