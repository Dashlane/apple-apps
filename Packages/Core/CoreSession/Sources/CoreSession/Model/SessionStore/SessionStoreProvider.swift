import CoreTypes
import Foundation

public struct SessionStoreProvider: SessionStoreProviderProtocol {
  enum Keys: String {
    case info = "info.json"
    case localKey
    case keys
    case currentLogin
  }

  public struct LoginStore: SessionStoreItem {
    let url: URL

    public func load() throws -> Login? {
      guard FileManager.default.fileExists(atPath: url.path) else {
        return nil
      }
      return try Data(contentsOf: url)
        .decode()
    }

    public func save(_ login: Login?) throws {
      if let login = login {
        try login
          .encode()
          .write(to: url)
      } else {
        try? FileManager.default.removeItem(at: url)
      }
    }
  }

  public struct LocalKeyStore: SessionStoreItem {
    let url: URL

    public func load() throws -> Data {
      try Data(contentsOf: url)
    }
    public func save(_ data: Data) throws {
      try data
        .write(to: url)
    }
  }

  public struct InfoStore: SessionStoreItem {
    let url: URL

    public func load() throws -> SessionInfo {
      return try Data(contentsOf: url)
        .decode()
    }
    public func save(_ info: SessionInfo) throws {
      try info
        .encode()
        .write(to: url)
    }
  }

  public struct KeysStore: SessionStoreItem {
    let url: URL
    let cryptoEngine: CryptoEngine

    public func load() throws -> SessionSecureKeys {
      return try Data(contentsOf: url)
        .decrypt(using: cryptoEngine)
        .decode()
    }
    public func save(_ info: SessionSecureKeys) throws {
      return
        try info
        .encode()
        .encrypt(using: cryptoEngine)
        .write(to: url)
    }
  }

  public init() {

  }

  public func currentLoginStore(forContainerURL baseURL: URL) throws -> LoginStore {
    LoginStore(url: baseURL.appendingPathComponent(Keys.currentLogin.rawValue))
  }

  public func infoStore(for login: Login, directory: SessionDirectory) throws -> InfoStore {
    InfoStore(
      url: URL(baseURL: directory.url.appendingPathComponent(Keys.info.rawValue), key: .info))
  }

  public func encryptedLocalKeyStore(
    for login: Login, info: SessionInfo, directory: SessionDirectory
  ) throws -> LocalKeyStore {
    LocalKeyStore(
      url: URL(
        baseURL: directory.url.appendingPathComponent(Keys.localKey.rawValue), key: .localKey))
  }

  public func keysStore(
    for login: Login, directory: SessionDirectory, using engineSet: StoreCryptoEngineSet,
    info: SessionInfo
  ) throws -> KeysStore {
    KeysStore(
      url: URL(baseURL: directory.url.appendingPathComponent(Keys.keys.rawValue), key: .keys),
      cryptoEngine: engineSet.local)
  }
}

extension URL {
  init(
    baseURL: URL,
    key: SessionStoreProvider.Keys
  ) {
    self.init(fileURLWithPath: key.rawValue, isDirectory: false, relativeTo: baseURL)
  }
}
