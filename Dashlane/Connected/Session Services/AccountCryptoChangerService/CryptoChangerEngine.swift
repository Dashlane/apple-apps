import CoreSession
import DashTypes
import Foundation

struct CryptoChangerEngine: DashTypes.CryptoEngine {

  let encryptCryptoEngine: CryptoEngine
  let decryptCryptoEngine: CryptoEngine
  init(current: CryptoEngine, new: CryptoEngine) {

    self.encryptCryptoEngine = new
    self.decryptCryptoEngine = current
  }

  func encrypt(_ data: Data) throws -> Data {
    return try encryptCryptoEngine.encrypt(data)
  }

  func decrypt(_ data: Data) throws -> Data {
    return try decryptCryptoEngine.decrypt(data)
  }
}
