import CoreTypes
import Foundation

public struct DeviceTransferSecretBoxImpl: DeviceTransferSecretBox {

  let cryptoEngine: DeviceTransferCryptoEngine

  public init(cryptoEngine: DeviceTransferCryptoEngine) {
    self.cryptoEngine = cryptoEngine
  }

  public func seal<T: Encodable>(_ data: T, nonce: Nonce?) throws -> (Base64EncodedString, Nonce) {
    let encodedData = try JSONEncoder().encode(data)
    return try cryptoEngine.encrypt(encodedData)
  }

  public func open<T: Decodable>(
    _ type: T.Type, from text: Base64EncodedString, nonce: CoreTypes.Base64EncodedString
  ) throws -> T {
    let decryptedData = try cryptoEngine.decrypt(text, nonce: nonce)
    return try JSONDecoder().decode(T.self, from: decryptedData)
  }

}
