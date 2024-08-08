import CoreCrypto
import CyrilKit
import DashTypes
import DocumentServices
import Foundation

extension CryptoConfiguration: DocumentServices.DocumentCryptoProvider {
  public func fileCryptoEngine(for key: CyrilKit.SymmetricKey) throws -> DashTypes.FileCryptoEngine
  {
    try self.makeCryptoEngine(secret: .key(key))
  }
}
