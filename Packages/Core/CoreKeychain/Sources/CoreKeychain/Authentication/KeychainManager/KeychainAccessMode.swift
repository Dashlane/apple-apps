import Foundation

public enum KeychainAccessMode {
    case whenDeviceUnlocked
    case afterBiometricAuthentication
    
    var accessModeAttribute: [CFString: Any] {
        switch self {
        case .whenDeviceUnlocked:
            return [kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly]
        case .afterBiometricAuthentication:
            return [kSecAttrAccessControl: SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenUnlockedThisDeviceOnly, SecAccessControlCreateFlags.biometryCurrentSet, nil)!]
        }
    }
}

