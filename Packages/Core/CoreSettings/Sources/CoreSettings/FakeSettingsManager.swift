import CoreTypes

public class FakeSettingsFactory: LocalSettingsFactory {

  var stores: [Login: LocalSettingsStoreMock]

  public init() {
    stores = [:]
  }

  public func fetchOrCreateSettings(for login: Login) throws -> LocalSettingsStore {
    if let store = stores[login] {
      return store
    }
    let store = LocalSettingsStoreMock()
    stores[login] = store
    return store
  }

  public func fetchOrCreateSettings(for login: Login, cryptoEngine: CoreTypes.CryptoEngine) throws
    -> LocalSettingsStore
  {
    return try fetchOrCreateSettings(for: login)
  }

  public func removeSettings(for login: Login) throws {
    stores.removeValue(forKey: login)
  }
}
