import Foundation
import Combine
import DashTypes

public enum UserLockSettingsKey: String, CaseIterable, LocalSettingsKey {
    case autoLockDelay = "KW_APP_PIN_AUTO_LOCK_TIME"
    case lockOnExit = "V8_KW_APP_LOCK_ON_EXIT"
    case pinCode = "V8_KW_APP_PIN_CODE_ACTIVATED"
    case biometric = "V8_KW_APP_TOUCH_ID_ACTIVATED"
    case biometricEnrolmentChanged = "V8_KW_APP_TOUCH_ID_ENROLLMENT_CHANGE"
    case pinCodeAttempts = "PIN_CODE_ATTEMPTS"
    case mpKeychainStorageExpirationDate = "expirationDateKWKeychainManagerSettingsKey"
    case resetMasterPasswordWithBiometricsReactivationNeeded
    case rememberMasterPassword
    case biometricSetData 

    public var type: Any.Type {
        switch self {
        case .biometric,
             .pinCode,
             .biometricEnrolmentChanged,
             .lockOnExit,
             .resetMasterPasswordWithBiometricsReactivationNeeded,
             .rememberMasterPassword:
            return Bool.self
        case .pinCodeAttempts:
            return [Date].self
        case .mpKeychainStorageExpirationDate:
            return Date.self
        case .autoLockDelay:
            return TimeInterval.self
        case .biometricSetData:
            return Data.self
        }
    }
}


public typealias UserLockSettings = KeyedSettings<UserLockSettingsKey>
