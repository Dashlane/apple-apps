import CoreCrypto
import CyrilKit
import Foundation
import SecurityDashboard

public struct DataLeakInformationDecryptor: DataLeakInformationDataDecryptor {
  let privateKey: PrivateKey

  public func decrypt(_ data: Data, using encryptedCipherKey: Data) throws -> Data {
    let decryptedKey = try RSA.Decrypter(privateKey: privateKey, variant: .oaep(.sha1))
      .decrypt(encryptedCipherKey)

    let engine = try CoreCrypto.CryptoConfiguration(encryptedData: data)
      .makeCryptoEngine(secret: .key(decryptedKey), fixedSalt: nil)
    let decrypted = try engine.decrypt(data)
    return decrypted
  }
}
