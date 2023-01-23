import Foundation
import CoreSession
import CoreKeychain
import DashlaneCrypto
import SwiftTreats
import DashTypes
import LocalAuthentication
import CoreSettings

public protocol SecureLockProviderProtocol {
    func secureLockMode(checkIsBiometricSetIntact: Bool) -> SecureLockMode
}

public extension SecureLockProviderProtocol {
    func secureLockMode(checkIsBiometricSetIntact: Bool = true) -> SecureLockMode {
        secureLockMode(checkIsBiometricSetIntact: checkIsBiometricSetIntact)
    }
}

public struct SecureLockProvider: SecureLockProviderProtocol {

    let login: Login
    public let keychainService: AuthenticationKeychainServiceProtocol
    let settings: UserLockSettings

    private var isBiometricSetIntact: Bool? {
        return try? settings.isBiometricSetIntact()
    }
    
    public init(login: Login, settings: LocalSettingsStore, keychainService: AuthenticationKeychainServiceProtocol) {
        let settings = settings.keyed(by: UserLockSettingsKey.self)
        self.init(login: login, settings: settings, keychainService: keychainService)
    }
    
    public init(login: Login, settings: UserLockSettings, keychainService: AuthenticationKeychainServiceProtocol) {
        self.login = login
        self.keychainService = keychainService
        self.settings = settings
    }
    
    public func secureLockMode(checkIsBiometricSetIntact: Bool = true) -> SecureLockMode {
        let masterKeyStatus = keychainService.masterKeyStatus(for: login)

        switch masterKeyStatus {
        case .available(accessMode: let accessMode) where accessMode == .whenDeviceUnlocked:
            let biometryActivated = settings[.biometric] == true
            let pinActivated = settings[.pinCode] == true
            let rememberMasterPasswordActivated = settings[.rememberMasterPassword] == true
            let pinCodeAttempts = PinCodeAttempts(internalStore: settings.internalStore)

            if rememberMasterPasswordActivated {
                assert(biometryActivated == false && pinActivated == false)
                return .rememberMasterPassword
            }

                        switch (biometryActivated, pinActivated) {
            case (true, true):
                guard let masterKey = try? keychainService.masterKey(for: login), let pin = try? keychainService.pincode(for: login) else {
                    assertionFailure("Unexpected state")
                    return .masterKey
                }

                                guard let biometry = Device.biometryType else {
                    return .pincode(code: pin, attempts: pinCodeAttempts, masterKey: masterKey)
                }
                
                if checkIsBiometricSetIntact && isBiometricSetIntact == false {
                    return .pincode(code: pin, attempts: pinCodeAttempts, masterKey: masterKey)
                }

                return .biometryAndPincode(biometry: biometry, code: pin, attempts: pinCodeAttempts, masterKey: masterKey)
            case (false, true):
                guard let masterKey = try? keychainService.masterKey(for: login), let pin = try? keychainService.pincode(for: login) else {
                    assertionFailure("Unexpected state")
                    return .masterKey
                }

                return .pincode(code: pin, attempts: pinCodeAttempts, masterKey: masterKey)
            case (true, false):
                assertionFailure("For biometry only, accessMode is expected to be afterBiometricAuthentication")
                return .masterKey
            default:
                                                try? keychainService.removeMasterKey(for: login)
                return .masterKey
            }
        case .available(accessMode: let accessMode) where accessMode == .afterBiometricAuthentication:
                                    guard let biometry = Device.biometryType else {
                return .masterKey
            }

            return .biometry(biometry)
        default:
            return .masterKey
        }
    }
}

extension SecureLockMode: SecureLockProviderProtocol {
    public func secureLockMode(checkIsBiometricSetIntact: Bool = true) -> SecureLockMode {
        return self
    }
}

public enum BiometrySetCheckError: Error {
    case biometryUnavailable
    case latestBiometricSetDataNotFound
}

public extension UserLockSettings {
        func isBiometricSetIntact() throws -> Bool {
        let context = LAContext()

        guard Device.biometryType != nil, context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: nil) else {
            throw BiometrySetCheckError.biometryUnavailable
        }

        let latestBiometricSetData = context.evaluatedPolicyDomainState

        guard let storedBiometricSetData = (self[.biometricSetData] as Data?) else {
            throw BiometrySetCheckError.latestBiometricSetDataNotFound
        }

        let hasChanged = (latestBiometricSetData != storedBiometricSetData)

        return !hasChanged
    }
}
