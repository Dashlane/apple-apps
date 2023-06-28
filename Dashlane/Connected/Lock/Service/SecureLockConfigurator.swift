import Foundation
import CoreSession
import CoreKeychain
import DashlaneAppKit
import SwiftTreats
import DashTypes
import CoreSettings
import LoginKit

public struct SecureLockConfigurator {
    let session: Session
    let keychainService: AuthenticationKeychainService
    let settings: UserLockSettings
    let pinCodeAttempts: PinCodeAttempts

    private enum ConvenientAuthenticationMode {
        case biometry
        case pin(code: String)
        case biometryAndPin(code: String)
        case rememberMasterPassword 
        case none
    }

    private var provider: SecureLockProvider {
        SecureLockProvider(login: session.login, settings: settings, keychainService: keychainService)
    }

    init(session: Session, keychainService: AuthenticationKeychainService, settings: UserLockSettings) {
        self.session = session
        self.keychainService = keychainService
        self.settings = settings
        self.pinCodeAttempts = .init(internalStore: settings.internalStore)
    }

    init(session: Session, keychainService: AuthenticationKeychainService, settings: LocalSettingsStore) {
        let settings = settings.keyed(by: UserLockSettingsKey.self)
        self.init(session: session, keychainService: keychainService, settings: settings)
    }

                func refreshMasterKeyExpiration() {
        if settings[.biometric] == true {
            try? enableBiometry()
        } else if settings[.pinCode] == true {
            if let pinCode = try? keychainService.pincode(for: session.login) {
                try? enablePinCode(pinCode)
            }
        } else if settings[.rememberMasterPassword] == true {
            try? enableRememberMasterPassword()
        }
    }

    private func setConvenientAuthentication(_ mode: ConvenientAuthenticationMode) throws {
        try? keychainService.removeMasterKey(for: session.login)

        switch mode {
        case .biometry:
            try saveMasterKeyForBiometry()

            settings[.biometric] = true
            settings[.pinCode] = false
            settings[.rememberMasterPassword] = false
        case .pin(code: let code):
            try saveMasterKeyForPin(code: code)

            settings[.biometric] = false
            settings[.pinCode] = true
            settings[.rememberMasterPassword] = false
        case .biometryAndPin(code: let code):
            try saveMasterKeyForPin(code: code)

            settings[.biometric] = true
            settings[.pinCode] = true
            settings[.rememberMasterPassword] = false
        case .rememberMasterPassword:
            try saveMasterKeyForRememberMasterPassword()

            settings[.biometric] = false
            settings[.pinCode] = false
            settings[.rememberMasterPassword] = true
        case .none:
            settings[.biometric] = false
            settings[.pinCode] = false
            settings[.rememberMasterPassword] = false
        }
    }

    private func saveMasterKeyForBiometry() throws {
        try keychainService.saveMasterKey(session.authenticationMethod.sessionKey,
                                          for: session.login,
                                          accessMode: .afterBiometricAuthentication)
    }

    private func saveMasterKeyForPin(code: String) throws {
        try keychainService.saveMasterKey(session.authenticationMethod.sessionKey,
                                          for: session.login,
                                          accessMode: .whenDeviceUnlocked)
        try keychainService.setPincode(code, for: session.login)
    }

    private func saveMasterKeyForRememberMasterPassword() throws {
        try keychainService.saveMasterKey(session.authenticationMethod.sessionKey,
                                          for: session.login,
                                          accessMode: .whenDeviceUnlocked)
    }
}

extension SecureLockConfigurator {
    var isBiometricActivated: Bool {
        switch provider.secureLockMode() {
        case .biometry, .biometryAndPincode:
            return true
        case .masterKey, .pincode, .rememberMasterPassword:
            return false
        }
    }

    func enableBiometry() throws {
        if settings[.pinCode] == true, let pincode = try? keychainService.pincode(for: session.login) {
            try setConvenientAuthentication(.biometryAndPin(code: pincode))
        } else {
            try setConvenientAuthentication(.biometry)
        }
    }

    func disableBiometry() throws {
        if settings[.pinCode] == true, let pincode = try? keychainService.pincode(for: session.login) {
            try setConvenientAuthentication(.pin(code: pincode))
        } else {
            try setConvenientAuthentication(isRememberMasterPasswordActivated ? .rememberMasterPassword : .none)
        }
    }
}

extension SecureLockConfigurator {
    var isPincodeActivated: Bool {
        switch provider.secureLockMode() {
        case .pincode, .biometryAndPincode:
            return true
        case .masterKey, .biometry, .rememberMasterPassword:
            return false
        }
    }

    var canActivatePinCode: Bool {
        Device.isDeviceProtected
    }

    func enablePinCode(_ code: String) throws {
        pinCodeAttempts.removeAll()
        if settings[.biometric] == true {
            try setConvenientAuthentication(.biometryAndPin(code: code))
        } else {
            try setConvenientAuthentication(.pin(code: code))
        }
    }

    func disablePinCode() throws {
        pinCodeAttempts.removeAll()
        if settings[.biometric] == true {
            try setConvenientAuthentication(.biometry)
        } else {
            try setConvenientAuthentication(isRememberMasterPasswordActivated ? .rememberMasterPassword : .none)
        }
    }
}

extension SecureLockConfigurator {

    var isRememberMasterPasswordActivated: Bool {
        if case .rememberMasterPassword = provider.secureLockMode() {
            return true
        } else {
            return false
        }
    }

    var canActivateRememberMasterPassword: Bool {
        return Device.isMac
    }

    func enableRememberMasterPassword() throws {
        try setConvenientAuthentication(.rememberMasterPassword)

    }

    func disableRememberMasterPassword() throws {
        try setConvenientAuthentication(.none)
    }

}

private extension AuthenticationKeychainService {
    func saveMasterKey(_ masterKey: CoreSession.MasterKey,
                       for login: Login,
                       accessMode: KeychainAccessMode) throws {
        switch masterKey {
        case let .masterPassword(masterPassword, serverKey):
            try save(.masterPassword(masterPassword),
                     for: login,
                     expiresAfter: AuthenticationKeychainService.defaultPasswordValidityPeriod,
                     accessMode: accessMode)
            if let serverKey = serverKey {
                try saveServerKey(serverKey, for: login)
            }
        case .ssoKey(let key):
            try save(
                .key(key),
                for: login,
                expiresAfter: AuthenticationKeychainService.defaultRemoteKeyValidityPeriod,
                accessMode: accessMode)
        }
    }
}

extension SecureLockConfigurator {
    static var mock: SecureLockConfigurator {
        let keychainService = AuthenticationKeychainService(cryptoEngine: FakeKeychainCryptoEngine(),
                                              keychainSettingsDataProvider: FakeSettingsFactory(),
                                              accessGroup: "")
        return SecureLockConfigurator(session: .mock,
                                      keychainService: keychainService,
                                      settings: .mock())
    }
}
