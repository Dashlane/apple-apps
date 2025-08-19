import CoreSession
import CoreSettings
import CoreTypes
import Foundation

public final class LoginSettingsImpl: LoginSettings {

  let login: Login
  let userSettings: UserSettings
  let lockSettings: UserLockSettings
  let keychainService: AuthenticationKeychainServiceProtocol

  public init(
    login: Login,
    settingsManager: LocalSettingsFactory,
    keychainService: AuthenticationKeychainServiceProtocol
  ) throws {
    self.login = login
    self.userSettings = try settingsManager.fetchOrCreateUserSettings(for: login)
    lockSettings = userSettings.internalStore.keyed(by: UserLockSettingsKey.self)
    self.keychainService = keychainService
  }

  public init(
    login: Login,
    userSettings: UserSettings,
    keychainService: AuthenticationKeychainServiceProtocol
  ) {
    self.login = login
    self.userSettings = userSettings
    self.lockSettings = userSettings.internalStore.keyed(by: UserLockSettingsKey.self)
    self.keychainService = keychainService
  }

  public var hasAutomaticallyLogout: Bool {
    get {
      return userSettings[.automaticallyLoggedOut] == true
    }
    set {
      userSettings[.automaticallyLoggedOut] = newValue
    }
  }

  public var isBiometryEnabled: Bool {
    get {
      lockSettings[.biometric] == true
    }
    set {
      lockSettings[.biometric] = newValue
    }
  }

  public func secureLockMode(checkIsBiometricSetIntact: Bool) -> SecureLockMode {
    let provider = SecureLockProvider(
      login: login,
      settings: lockSettings,
      keychainService: keychainService)
    return provider.secureLockMode(checkIsBiometricSetIntact: checkIsBiometricSetIntact)
  }
}
