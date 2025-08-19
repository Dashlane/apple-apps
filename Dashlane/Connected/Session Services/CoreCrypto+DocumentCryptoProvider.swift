import CoreCrypto
import CoreTypes
import CyrilKit
import DocumentServices
import Foundation

extension CryptoConfiguration: DocumentServices.DocumentCryptoProvider {
  public func fileCryptoEngine(for key: CyrilKit.SymmetricKey) throws -> CoreTypes.FileCryptoEngine
  {
    try self.makeCryptoEngine(secret: .key(key))
  }
}
