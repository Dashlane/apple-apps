import Foundation

public class BasicKeyedStore<Key: StoreKey>: KeyedStore {
  private let persistenceEngine: StorePersistenceEngine

  public init(persistenceEngine: StorePersistenceEngine) {
    self.persistenceEngine = persistenceEngine
  }

  public func exists(for key: Key) -> Bool {
    return persistenceEngine.exists(for: key)
  }

  public func store(_ data: Data?, for key: Key) throws {
    guard let data = data else {
      try persistenceEngine.write(nil, for: key)
      return
    }

    try persistenceEngine.write(data, for: key)
  }

  public func retrieveData(for key: Key) throws -> Data {
    guard let data = try? persistenceEngine.read(for: key) else {
      throw KeyedStoreError.noValue(key)
    }
    return data
  }
}
