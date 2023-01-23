import Foundation
import CoreSession

public protocol FeatureFlipServiceStorage {
    func hasStoredData() -> Bool
    func store(_ data: Data) throws
    func retrieve() throws -> Data
}

final public class FeatureStorage: FeatureFlipServiceStorage {

    enum FeatureStoreKey: String, StoreKey {
        case flips
    }

    private let session: Session

    private lazy var secureStore: KeyedSecureStore<FeatureStoreKey> = {
        return session.secureStore(for: FeatureStoreKey.self)
    }()

    init(session: Session) {
        self.session = session
    }

    public func hasStoredData() -> Bool {
       secureStore.exists(for: .flips)
    }

    public func store(_ data: Data) throws {
        try secureStore.store(data, for: .flips)
    }

    public func retrieve() throws -> Data {
        return try secureStore.retrieveData(for: .flips)
    }
}
