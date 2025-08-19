import CoreTypes
import Foundation

public protocol LoginSettings: Sendable {
  var hasAutomaticallyLogout: Bool { get set }
  var isBiometryEnabled: Bool { get set }
  func secureLockMode(checkIsBiometricSetIntact: Bool) -> SecureLockMode
}

public struct LoginSettingsMock: LoginSettings {

  public var hasAutomaticallyLogout: Bool = false
  public var isBiometryEnabled: Bool = false

  let lockMode: SecureLockMode

  init(secureLockMode: SecureLockMode = .masterKey, hasAutomaticallyLogout: Bool) {
    self.lockMode = secureLockMode
  }

  public func secureLockMode(checkIsBiometricSetIntact: Bool) -> SecureLockMode {
    lockMode
  }
}

extension LoginSettings where Self == LoginSettingsMock {
  public static func mock(
    secureLockMode: SecureLockMode = .masterKey, hasAutomaticallyLogout: Bool = false
  ) -> LoginSettings {
    LoginSettingsMock(
      secureLockMode: secureLockMode, hasAutomaticallyLogout: hasAutomaticallyLogout)
  }
}

public protocol LoginSettingsProvider {
  func makeSettings(for login: Login) throws -> LoginSettings
}

public struct LoginSettingsProviderMock: LoginSettingsProvider {

  let lockMode: SecureLockMode
  let hasAutomaticallyLogout: Bool

  init(secureLockMode: SecureLockMode = .masterKey, hasAutomaticallyLogout: Bool) {
    self.lockMode = secureLockMode
    self.hasAutomaticallyLogout = hasAutomaticallyLogout
  }

  public func makeSettings(for login: CoreTypes.Login) throws -> any LoginSettings {
    LoginSettingsMock(secureLockMode: lockMode, hasAutomaticallyLogout: hasAutomaticallyLogout)
  }
}

extension LoginSettingsProvider where Self == LoginSettingsProviderMock {
  public static func mock(secureLockMode: SecureLockMode, hasAutomaticallyLogout: Bool = false)
    -> LoginSettingsProvider
  {
    LoginSettingsProviderMock(
      secureLockMode: secureLockMode, hasAutomaticallyLogout: hasAutomaticallyLogout)
  }
}
