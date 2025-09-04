import CoreTypes
import Foundation

public struct CryptoChangerEngine: CryptoEngine {
  enum Error: Swift.Error {
    case invalidBase64String
  }

  private let encryptCryptoEngine: EncryptEngine
  private let decryptCryptoEngine: DecryptEngine
  public init(current: DecryptEngine, new: EncryptEngine) {
    self.encryptCryptoEngine = new
    self.decryptCryptoEngine = current
  }

  public func encrypt(_ data: Data) throws -> Data {
    return try encryptCryptoEngine.encrypt(data)
  }

  public func decrypt(_ data: Data) throws -> Data {
    return try decryptCryptoEngine.decrypt(data)
  }

  func recryptBase64Encoded(_ string: String) throws -> String {
    guard let data = Data(base64URLEncoded: string) else {
      throw Error.invalidBase64String
    }

    let plain = try decrypt(data)
    let encrypted = try encrypt(plain)

    return encrypted.base64EncodedString()
  }
}
