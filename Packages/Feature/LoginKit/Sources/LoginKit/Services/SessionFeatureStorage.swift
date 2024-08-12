import CoreFeature
import CoreSession
import DashTypes
import DashlaneAPI
import Foundation

final public class SessionFeatureStorage: FeatureFlipServiceStorage {

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

extension FeatureService {
  public convenience init(
    session: Session,
    apiClient: UserDeviceAPIClient.Features,
    apiAppClient: AppAPIClient.Features,
    logger: Logger,
    useCacheOnly: Bool = false
  ) async {
    await self.init(
      login: session.login,
      apiClient: apiClient,
      apiAppClient: apiAppClient,
      storage: SessionFeatureStorage(session: session),
      labsStorage: SessionLabsStorage(session: session),
      logger: logger,
      useCacheOnly: useCacheOnly)
  }
}
