import Foundation
import SwiftTreats
import UserTrackingFoundation

extension Definition.OsType {
  static var current: Definition.OsType {
    if Device.is(.mac) {
      return .macOs
    } else if Device.is(.pad) {
      return .ipad
    } else if Device.is(.watch) {
      return .watchOs
    } else {
      return .iphone
    }
  }
}
extension Definition.Platform {
  public static var current: Definition.Platform {
    if Device.is(.mac) {
      return .catalyst
    } else {
      return .ios
    }
  }
}
