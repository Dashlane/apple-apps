import CryptoKit
import Foundation
import LogFoundation

extension ECDH {
  @Loggable
  enum CryptoError: Error {
    case couldNotDecrypt
    case couldNotEncrypt
  }

  struct CryptoEngine {
    let symmetricKey: SymmetricKey

    public init(symmetricKey: SymmetricKey) {
      self.symmetricKey = symmetricKey
    }

    public func encrypt(text: String) throws -> String {
      guard let textData = text.data(using: .utf8) else {
        throw CryptoError.couldNotEncrypt
      }
      guard let encrypted = try AES.GCM.seal(textData, using: symmetricKey).combined else {
        throw CryptoError.couldNotEncrypt
      }
      return encrypted.base64EncodedString()
    }

    public func decrypt(text: String) throws -> String {
      guard let data = Data(base64Encoded: text) else {
        throw CryptoError.couldNotDecrypt
      }
      let sealedBox = try AES.GCM.SealedBox(combined: data)
      let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)

      guard let text = String(data: decryptedData, encoding: .utf8) else {
        throw CryptoError.couldNotDecrypt
      }
      return text
    }
  }
}
