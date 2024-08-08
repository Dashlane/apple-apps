import CoreFeature
import CoreSession
import Foundation

public struct SessionLabsStorage: LabsServiceStorage {

  enum LabsStoreKey: String, StoreKey {
    case labs
  }

  private var secureStore: KeyedSecureStore<LabsStoreKey>

  public init(session: Session) {
    self.secureStore = session.secureStore(for: LabsStoreKey.self)
  }

  public func hasStoredData() -> Bool {
    secureStore.exists(for: .labs)
  }

  public func store(_ data: Data) throws {
    try secureStore.store(data, for: .labs)
  }

  public func retrieve() throws -> Data {
    return try secureStore.retrieveData(for: .labs)
  }
}
