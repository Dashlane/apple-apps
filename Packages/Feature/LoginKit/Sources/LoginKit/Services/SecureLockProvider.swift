import CoreKeychain
import CoreSession
import CoreSettings
import CoreTypes
import Foundation
import LocalAuthentication
import SwiftTreats

public protocol SecureLockProviderProtocol {
  func secureLockMode(checkIsBiometricSetIntact: Bool) -> SecureLockMode
}

extension SecureLockProviderProtocol {
  public func secureLockMode(checkIsBiometricSetIntact: Bool = true) -> SecureLockMode {
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

  public init(
    login: Login, settings: LocalSettingsStore,
    keychainService: AuthenticationKeychainServiceProtocol
  ) {
    let settings = settings.keyed(by: UserLockSettingsKey.self)
    self.init(login: login, settings: settings, keychainService: keychainService)
  }

  public init(
    login: Login, settings: UserLockSettings, keychainService: AuthenticationKeychainServiceProtocol
  ) {
    self.login = login
    self.keychainService = keychainService
    self.settings = settings
  }

  public func secureLockMode(checkIsBiometricSetIntact: Bool = true) -> SecureLockMode {
    let masterKeyStatus = keychainService.masterKeyStatus(for: login)

    switch masterKeyStatus {
    case .available(let accessMode) where accessMode == .whenDeviceUnlocked:
      let biometryActivated = settings[.biometric] == true
      let pinActivated = settings[.pinCode] == true
      let rememberMasterPasswordActivated = settings[.rememberMasterPassword] == true

      if rememberMasterPasswordActivated {
        assert(biometryActivated == false && pinActivated == false)
        return .rememberMasterPassword
      }

      switch (biometryActivated, pinActivated) {
      case (true, true):
        guard let masterKey = try? keychainService.masterKey(for: login),
          let pin = try? keychainService.pincode(for: login)
        else {
          assertionFailure("Unexpected state")
          return .masterKey
        }

        let serverKey = keychainService.serverKey(for: login)
        let lock = SecureLockMode.PinCodeLock(
          code: pin, masterKey: masterKey.coreSessionMasterKey(withServerKey: serverKey))

        guard let biometry = Device.biometryType else {
          return .pincode(lock)
        }

        if checkIsBiometricSetIntact && isBiometricSetIntact == false {
          return .pincode(lock)
        }

        return .biometryAndPincode(biometry: biometry, pinCodeLock: lock)
      case (false, true):
        guard let masterKey = try? keychainService.masterKey(for: login),
          let pin = try? keychainService.pincode(for: login)
        else {
          assertionFailure("Unexpected state")
          return .masterKey
        }

        let serverKey = keychainService.serverKey(for: login)
        let lock = SecureLockMode.PinCodeLock(
          code: pin, masterKey: masterKey.coreSessionMasterKey(withServerKey: serverKey))

        return .pincode(lock)
      case (true, false):
        #if targetEnvironment(simulator)
          guard let biometry = Device.biometryType else {
            return .masterKey
          }
          return .biometry(biometry)
        #endif
        assertionFailure(
          "For biometry only, accessMode is expected to be afterBiometricAuthentication")
        return .masterKey
      default:
        try? keychainService.removeMasterKey(for: login)
        return .masterKey
      }
    case .available(let accessMode) where accessMode == .afterBiometricAuthentication:
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

extension UserLockSettings {
  public func isBiometricSetIntact() throws -> Bool {
    let context = LAContext()

    guard Device.biometryType != nil,
      context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: nil)
    else {
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

extension CoreTypes.MasterKey {
  func coreSessionMasterKey(withServerKey serverKey: String? = nil) -> CoreSession.MasterKey {
    switch self {
    case .masterPassword(let password):
      return .masterPassword(password, serverKey: serverKey)
    case .key(let data):
      return .ssoKey(data)
    }
  }
}

extension SecureLockProvider {
  public static var mock: SecureLockProviderProtocol {
    SecureLockProvider(login: Login("_"), settings: .mock(), keychainService: .mock)
  }
}
