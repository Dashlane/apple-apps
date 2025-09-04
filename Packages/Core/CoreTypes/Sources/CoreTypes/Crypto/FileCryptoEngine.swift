import Foundation

public protocol FileCryptoEngine {
  func encrypt(_ url: URL, to: URL) throws
  func decrypt(_ url: URL, to: URL) throws
}

extension MockCryptoEngine: FileCryptoEngine {
  public func encrypt(_ url: URL, to destination: URL) throws {
    try Data(contentsOf: url)
      .encrypt(using: self)
      .write(to: destination)
  }

  public func decrypt(_ url: URL, to destination: URL) throws {
    try Data(contentsOf: url)
      .decrypt(using: self)
      .write(to: destination)
  }
}

extension FileCryptoEngine where Self == MockCryptoEngine {
  public static func mock(_ mode: MockCryptoEngine.OperationMode = .reverseEncrypt)
    -> MockCryptoEngine
  {
    return MockCryptoEngine(mode: mode)
  }
}
