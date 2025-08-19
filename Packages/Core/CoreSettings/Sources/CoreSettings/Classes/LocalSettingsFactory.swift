import CoreTypes
import Foundation

public protocol LocalSettingsFactory {
  func fetchOrCreateSettings(for login: Login) throws -> LocalSettingsStore
  func fetchOrCreateSettings(for login: Login, cryptoEngine: CryptoEngine) throws
    -> LocalSettingsStore
  func removeSettings(for login: Login) throws
}

public struct LocalSettingsFactoryMock: LocalSettingsFactory {

  let store: LocalSettingsStore

  init() {
    store = .mock()
  }
  public func fetchOrCreateSettings(for login: CoreTypes.Login) throws -> LocalSettingsStore {
    store
  }

  public func fetchOrCreateSettings(
    for login: CoreTypes.Login, cryptoEngine: CoreTypes.CryptoEngine
  ) throws -> LocalSettingsStore {
    store
  }

  public func removeSettings(for login: CoreTypes.Login) throws {
    store.delete(login.email)
  }
}

extension LocalSettingsFactory where Self == LocalSettingsFactoryMock {
  public static var mock: LocalSettingsFactory {
    LocalSettingsFactoryMock()
  }
}
