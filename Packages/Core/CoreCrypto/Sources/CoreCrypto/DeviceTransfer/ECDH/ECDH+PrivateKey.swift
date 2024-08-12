import CryptoKit
import Foundation

extension ECDH.PrivateKey {
  public func symmetricKey(
    withPublicKey publicKeyData: Data, base64EncodedSalt salt: String, outputByteCount: Int = 64
  ) throws -> SymmetricKey {
    let publicKey = try Curve25519.KeyAgreement.PublicKey(rawRepresentation: [UInt8](publicKeyData))
    let sharedSecret = try self.sharedSecretFromKeyAgreement(with: publicKey)
    let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
      using: SHA256.self,
      salt: Data(base64Encoded: salt)!,
      sharedInfo: Data(),
      outputByteCount: outputByteCount
    )
    return symmetricKey
  }
}
