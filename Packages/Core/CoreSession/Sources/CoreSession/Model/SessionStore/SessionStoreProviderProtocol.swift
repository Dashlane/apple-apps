import DashTypes
import Foundation

public protocol SessionStoreItem {
  associatedtype Item
  func load() throws -> Item
  func save(_ data: Item) throws
}

public protocol SessionStoreProviderProtocol {
  associatedtype LoginStore: SessionStoreItem where LoginStore.Item == Login?
  associatedtype InfoStore: SessionStoreItem where InfoStore.Item == SessionInfo
  associatedtype LocalKeyStore: SessionStoreItem where LocalKeyStore.Item == Data
  associatedtype KeysStore: SessionStoreItem where KeysStore.Item == SessionSecureKeys

  func currentLoginStore(forContainerURL baseURL: URL) throws -> LoginStore
  func infoStore(for login: Login, directory: SessionDirectory) throws -> InfoStore
  func encryptedLocalKeyStore(for login: Login, info: SessionInfo, directory: SessionDirectory)
    throws -> LocalKeyStore
  func keysStore(
    for login: Login, directory: SessionDirectory, using engineSet: StoreCryptoEngineSet,
    info: SessionInfo
  ) throws -> KeysStore
}

public struct StoreCryptoEngineSet {
  public let session: CryptoEngine
  public let local: CryptoEngine

  public init(session: CryptoEngine, local: CryptoEngine) {
    self.session = session
    self.local = local
  }
}
