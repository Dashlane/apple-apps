import DashTypes
import Foundation

extension Session {
  public func secureStore<K: StoreKey>(for key: K.Type) -> KeyedSecureStore<K> {
    return KeyedSecureStore(cryptoEngine: localCryptoEngine, persistenceEngine: directory)
  }
  public func store<K: StoreKey>(for key: K.Type) -> BasicKeyedStore<K> {
    return BasicKeyedStore(persistenceEngine: directory)
  }
}
