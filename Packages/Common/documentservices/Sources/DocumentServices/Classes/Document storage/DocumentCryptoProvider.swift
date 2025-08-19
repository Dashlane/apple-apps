import CoreTypes
import CyrilKit
import Foundation

public protocol DocumentCryptoProvider {
  func fileCryptoEngine(for key: SymmetricKey) throws -> FileCryptoEngine
}

public struct DocumentCryptoMockProvider: DocumentCryptoProvider {
  let provider: (SymmetricKey) throws -> FileCryptoEngine

  public func fileCryptoEngine(for key: SymmetricKey) throws -> FileCryptoEngine {
    return try provider(key)
  }
}

extension DocumentCryptoProvider where Self == DocumentCryptoMockProvider {
  public static func mock(
    provider: @escaping (SymmetricKey) throws -> FileCryptoEngine = { _ in .mock() }
  ) -> DocumentCryptoMockProvider {
    DocumentCryptoMockProvider(provider: provider)
  }
}
