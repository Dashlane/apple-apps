import Foundation
import DashlaneReportKit
import DashlaneAppKit
import SwiftTreats

struct SecuritySettingsLogger {
    let usageLogService: UsageLogServiceProtocol

    enum Origin: String {
        case onboarding
        case securitySettings
    }

    private enum SecurityType {
        case faceID(Bool)
        case touchID(Bool)
        case pinCode(Bool)

        var action: String {
            switch self {
            case .faceID(true):
                return "useFaceIDOn"
            case .faceID(false):
                return "useFaceIDOff"
            case .touchID(true):
                return "useTouchIDOn"
            case .touchID(false):
                return "useTouchIDOff"
            case .pinCode(true):
                return "usePinCodeOn"
            case .pinCode(false):
                return "usePinCodeOff"
            }
        }
    }

    public func logBiometryStatus(isEnabled: Bool, origin: Origin) {
        switch Device.biometryType {
        case .faceId:
            usageLogService.post(UsageLogCode35UserActionsMobile.init(type: origin.rawValue, action: SecurityType.faceID(isEnabled).action))
        case .touchId:
            usageLogService.post(UsageLogCode35UserActionsMobile.init(type: origin.rawValue, action: SecurityType.touchID(isEnabled).action))
        default: break
        }

        if isEnabled {
            logPinStatus(isEnabled: false, origin: origin)
        }
    }

    public func logPinStatus(isEnabled: Bool, origin: Origin) {
        usageLogService.post(UsageLogCode35UserActionsMobile.init(type: origin.rawValue, action: SecurityType.pinCode(isEnabled).action))
    }
}

extension UsageLogServiceProtocol {
    var securitySettings: SecuritySettingsLogger {
        return SecuritySettingsLogger(usageLogService: self)
    }
}
