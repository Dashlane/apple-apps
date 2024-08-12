import CommonCrypto
import CryptoKit
import Foundation

public enum AES {

  public static func cbc(key: SymmetricKey, initializationVector: Data, padding: Padding? = nil)
    throws -> EncryptionEngine & StreamEncryptionEngine
  {
    try CCEncryptionEngine(
      algorithm: .aes, mode: .cbc, padding: padding, key: key,
      initializationVector: initializationVector)
  }

  public static func ecb(key: SymmetricKey, padding: Padding? = nil) throws -> EncryptionEngine
    & StreamEncryptionEngine
  {
    try CCEncryptionEngine(
      algorithm: .aes, mode: .ecb, padding: padding, key: key, initializationVector: Data())
  }
}
