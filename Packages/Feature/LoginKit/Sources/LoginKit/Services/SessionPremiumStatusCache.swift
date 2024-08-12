import CorePremium
import CoreSession
import Foundation

public struct SessionPremiumStatusCache: PremiumStatusCache, Sendable {
  enum Key: String, StoreKey {
    case premiumStatusCache
  }

  let store: KeyedSecureStore<Key>

  public init(session: Session) {
    store = session.secureStore(for: Key.self)
  }

  public func retrievePremiumStatus() throws -> CorePremium.Status {
    try store.retrieve(CorePremium.Status.self, for: .premiumStatusCache)
  }

  public func savePremiumStatus(_ status: CorePremium.Status) throws {
    try store.store(status, for: .premiumStatusCache)
  }
}
