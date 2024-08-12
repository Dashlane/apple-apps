import CryptoKit
import DashTypes
import Foundation
import Sodium

public struct DeviceTransferCryptoEngine: Sendable {

  public typealias SymmetricKey = [UInt8]

  public typealias EncryptedData = Base64EncodedString

  public typealias Nonce = [UInt8]

  enum CryptoError: Error {
    case couldNotDecrypt
    case couldNotEncrypt
    case notBase64Encoded
  }

  let symmetricKey: SymmetricKey

  let secretBox: SecretBox

  public init(symmetricKey: SymmetricKey) {
    self.symmetricKey = symmetricKey
    self.secretBox = Sodium().secretBox
  }

  public func encrypt(_ data: Data, nonce: Nonce? = nil) throws -> (EncryptedData, Nonce) {
    let nonce = nonce ?? secretBox.nonce()
    guard let encrypted = secretBox.seal(message: data.bytes, secretKey: symmetricKey, nonce: nonce)
    else {
      throw CryptoError.couldNotEncrypt
    }
    return (Data(bytes: encrypted, count: encrypted.count).base64EncodedString(), nonce)
  }

  public func decrypt(_ text: EncryptedData, nonce: Base64EncodedString) throws -> Data {
    guard let data = Data(base64Encoded: text), let nonce = Data(base64Encoded: nonce) else {
      throw CryptoError.notBase64Encoded
    }
    guard
      let decryptedData = secretBox.open(
        authenticatedCipherText: data.bytes, secretKey: symmetricKey, nonce: nonce.bytes)
    else {
      throw CryptoError.couldNotDecrypt
    }

    return Data(bytes: decryptedData, count: decryptedData.count)
  }
}
