import CoreKeychain
import CoreSession
import CoreSettings
import DashTypes
import Foundation

extension SettingsManager: LocalSettingsFactory {
  public func fetchOrCreateSettings(for login: Login) throws -> LocalSettingsStore {
    let sessionDirectory = try SessionDirectory(
      baseURL: ApplicationGroup.fiberSessionsURL, login: login)
    let url = try sessionDirectory.storeURL(for: StoreIdentifier.localSettings, in: .app)

    return try fetchOrCreateSettings(
      for: url,
      login: login,
      fileManager: sessionDirectory.fileManager
    )
  }

  public func fetchOrCreateSettings(
    for login: Login,
    cryptoEngine: DashTypes.CryptoEngine
  ) throws -> LocalSettingsStore {
    let settings = try fetchOrCreateSettings(for: login)
    self.cryptoEngine = cryptoEngine
    return settings
  }

  public func removeSettings(for login: Login) throws {
    let sessionDirectory = try SessionDirectory(
      baseURL: ApplicationGroup.fiberSessionsURL, login: login)
    let url = try sessionDirectory.storeURL(for: .localSettings, in: .app)

    removeSettings(for: url)
  }
}

extension SettingsManager: KeychainSettingsDataProvider {
  public func provider(for login: Login) throws -> SettingsDataProvider {
    try fetchOrCreateSettings(for: login).keyed(by: UserLockSettingsKey.self)
  }
}

extension FakeSettingsFactory: KeychainSettingsDataProvider {
  public func fetchOrCreateSettings(for session: Session) throws -> LocalSettingsStore {
    return try fetchOrCreateSettings(for: session.login)
  }

  public func provider(for login: Login) throws -> SettingsDataProvider {
    try fetchOrCreateSettings(for: login).keyed(by: UserLockSettingsKey.self)
  }
}
