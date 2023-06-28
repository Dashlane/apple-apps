import Foundation
import SwiftTreats

extension Definition.OsType {
    static var current: Definition.OsType {
        if Device.isMac {
            return .macOs
        } else if Device.isIpad {
            return .ipad
        } else {
            return .iphone
        }
    }
}
public extension Definition.Platform {
    static var current: Definition.Platform {
        if Device.isMac {
            return .catalyst
        } else {
            return .ios
        }
    }
}
